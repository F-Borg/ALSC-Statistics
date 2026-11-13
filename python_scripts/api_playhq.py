"""
Pulls cricket match data from the PlayHQ public API (see playhq-openapi.yml)
and writes it out in the exact same data/[season]/[grade]/Rnd_[round]/ .md
format that scrape_scorecard.py produces, so it can be manually checked /
edited before wrangle_match_data.wrangle_match_data() loads it.
"""

import os
import re
from datetime import datetime, timedelta
from pathlib import Path
from zoneinfo import ZoneInfo

import pandas as pd
import requests

BASE_URL = "https://api.playhq.com"
DEFAULT_CREDENTIALS_PATH = '.api_credentials.yml'

# team name our club plays under on PlayHQ - same regex used in utility.py/check_player_ids
OUR_CLUB_REGEX = r'(Adelaide (Junior )?Bulldogs|Adelaide Lutheran|\bADE\b)'

ORDINALS = {1: '1st', 2: '2nd', 3: '3rd', 4: '4th', 5: '5th'}


def _parse_simple_yaml(path):
    """Parses a flat two-level YAML file (top-level `key:` blocks of indented `key: value`
    pairs) without requiring pyyaml."""
    blocks = {}
    current = None
    for line in path.read_text().splitlines():
        if not line.strip() or line.strip().startswith('#'):
            continue
        if not line.startswith((' ', '\t')):
            current = line.split(':', 1)[0].strip()
            blocks[current] = {}
        elif current is not None:
            key, _, value = line.strip().partition(':')
            blocks[current][key.strip()] = value.strip()
    return blocks


def _load_credentials(path=DEFAULT_CREDENTIALS_PATH, association=None):
    """
    Reads a credentials block out of .api_credentials.yml without requiring pyyaml.

    The file may hold multiple named blocks, one per association, e.g.
    `credentials_asca:`, `credentials_saca_junior:`, `credentials_atca:`. Pass
    association='asca' to select `credentials_asca`. If association is not given,
    falls back to the old flat `credentials:` block, or - if there's exactly one
    `credentials_*` block in the file - that one.
    """
    path = Path(path)
    if not path.exists():
        return {}

    try:
        import yaml
        with open(path) as f:
            blocks = yaml.safe_load(f) or {}
    except ImportError:
        blocks = _parse_simple_yaml(path)

    if association is not None:
        key = association if association.startswith('credentials') else f'credentials_{association}'
        if key not in blocks:
            available = sorted(k for k in blocks if k.startswith('credentials'))
            raise Exception(f"No '{key}' block found in {path}; available blocks: {available}")
        return blocks[key] or {}

    if 'credentials' in blocks:
        return blocks['credentials'] or {}

    cred_blocks = {k: v for k, v in blocks.items() if k.startswith('credentials_')}
    if len(cred_blocks) == 1:
        return next(iter(cred_blocks.values())) or {}
    if len(cred_blocks) > 1:
        raise Exception(
            f"Multiple credential blocks found in {path} ({sorted(cred_blocks)}); "
            f"pass association= to PlayHQClient to select one"
        )
    return {}


class PlayHQClient:
    """
    Thin wrapper around the PlayHQ public API (x-api-key / x-phq-tenant auth).

    Credentials are resolved in order: explicit constructor args, PLAYHQ_* env vars,
    then a `credentials_<association>:` block in .api_credentials.yml (client_id is
    used as the api key, since that's what's provided there; add an explicit
    api_key/tenant entry to that block to override). Pass association='asca' (etc.)
    to select which block to use when the file has more than one.
    """

    def __init__(self, api_key=None, tenant=None, organisation_id=None, association=None,
                 credentials_path=DEFAULT_CREDENTIALS_PATH, timeout=30):
        creds = _load_credentials(credentials_path, association=association)

        self.api_key = api_key or os.environ.get('PLAYHQ_API_KEY') or creds.get('api_key') or creds.get('client_id')
        self.tenant = tenant or os.environ.get('PLAYHQ_TENANT') or creds.get('tenant')
        self.organisation_id = organisation_id or os.environ.get('PLAYHQ_ORGANISATION_ID') or creds.get('organisation_id')
        self.base_url = creds.get('host') or BASE_URL

        if not self.api_key:
            raise Exception('No PlayHQ API key found (pass api_key=, set PLAYHQ_API_KEY, or add client_id/api_key to .api_credentials.yml)')
        if not self.tenant:
            raise Exception('No PlayHQ tenant found (pass tenant=, set PLAYHQ_TENANT, or add tenant to .api_credentials.yml)')

        self.timeout = timeout
        self.headers = {
            'x-api-key': self.api_key,
            'x-phq-tenant': self.tenant,
            'Accept': 'application/json',
        }

    def _get(self, path, params=None):
        resp = requests.get(f"{self.base_url}{path}", headers=self.headers, params=params, timeout=self.timeout)
        if not resp.ok:
            raise Exception(f"PlayHQ API error {resp.status_code} for {path}: {resp.text}")
        return resp.json()

    def _get_paginated_list(self, path, params=None):
        """For endpoints that return {data: [...], metadata: {hasMore, nextCursor}}"""
        params = dict(params or {})
        results = []
        while True:
            body = self._get(path, params=params)
            results.extend(body.get('data', []))
            metadata = body.get('metadata', {})
            if not metadata.get('hasMore'):
                break
            params['cursor'] = metadata['nextCursor']
        return results

    def get_seasons(self, organisation_id=None):
        """/v1/organisations/{id}/seasons - list of seasons for an association"""
        organisation_id = organisation_id or self.organisation_id
        if not organisation_id:
            raise Exception('No organisation_id given (pass one, or add organisation_id to .api_credentials.yml)')
        return self._get_paginated_list(f"/v1/organisations/{organisation_id}/seasons")

    def get_grades(self, season_id):
        """/v1/seasons/{id}/grades - list of grades under a season"""
        return self._get_paginated_list(f"/v1/seasons/{season_id}/grades")

    def get_grade_fixture(self, grade_id):
        """/v2/grades/{id}/games - full fixture (rounds/games/teams/playingSurfaces) for a grade"""
        return self._get(f"/v2/grades/{grade_id}/games")

    def get_game_summary(self, game_id):
        """/v2/games/{id}/summary - full scorecard for a single game"""
        params = {}
        data = None
        while True:
            body = self._get(f"/v2/games/{game_id}/summary", params=params)
            if data is None:
                data = body['data']
            else:
                data['appearances'].extend(body['data'].get('appearances', []))
            metadata = body.get('metadata', {})
            if not metadata.get('hasMore'):
                break
            params['cursor'] = metadata['nextCursor']
        return data


#########################################################################################################################
# helpers
#########################################################################################################################

def _stat(statistics, stat_type, default=0):
    for s in statistics or []:
        if s['type'] == stat_type:
            return s['value']
    return default


def _format_overs(value):
    value = float(value or 0)
    if value == int(value):
        return str(int(value))
    return str(value)


def _appearance_name(appearance):
    if appearance is None:
        return 'Fill-in'
    first = appearance.get('firstName')
    last = appearance.get('lastName')
    if not first or not last:
        return 'Fill-in'
    return f"{first} {last}"


def _name_by_id(appearance_id, appearances_by_id):
    return _appearance_name(appearances_by_id.get(appearance_id))


def _build_dismissal_map(period):
    """appearanceId (batter) -> {type, bowler_id, fielder_ids} from a period's sharedStatistics"""
    dismissals = {}
    for stat in period.get('sharedStatistics') or []:
        entries = stat['appearances']
        batter_id = next((e['id'] for e in entries if e['role'] == 'BATTING'), None)
        bowler_id = next((e['id'] for e in entries if e['role'] == 'BOWLING'), None)
        fielder_ids = [e['id'] for e in entries if e['role'] == 'FIELDING']
        if batter_id:
            dismissals[batter_id] = {'type': stat['type'], 'bowler_id': bowler_id, 'fielder_ids': fielder_ids}
    return dismissals


def _how_out_text(status, dismissal, appearances_by_id):
    if status == 'NOT_OUT':
        return 'not out'
    if status is None:
        return 'did not bat'
    if status != 'OUT':
        return status.lower().replace('_', ' ')
    if dismissal is None:
        print('Warning: OUT batter with no matching dismissal in sharedStatistics')
        return 'out'

    dtype = dismissal['type']
    bowler = _name_by_id(dismissal.get('bowler_id'), appearances_by_id) if dismissal.get('bowler_id') else None
    fielder_ids = dismissal.get('fielder_ids') or []
    fielder = _name_by_id(fielder_ids[0], appearances_by_id) if fielder_ids else None

    if dtype == 'CAUGHT':
        if fielder and bowler and fielder == bowler:
            return f"c&b: {bowler}"
        return f"c: {fielder or 'Unknown'} b: {bowler or 'Unknown'}"
    if dtype == 'BOWLED':
        return f"b: {bowler or 'Unknown'}"
    if dtype == 'LEG_BEFORE_WICKET':
        return f"lbw: {bowler or 'Unknown'}"
    if dtype == 'STUMPED':
        return f"st: {fielder or 'Unknown'} b: {bowler or 'Unknown'}"
    if dtype == 'RUN_OUT':
        return f"run out: {fielder or 'Unknown'}"
    if dtype == 'HIT_WICKET':
        return f"hit wicket b: {bowler or 'Unknown'}"
    if dtype == 'RETIRED_HURT':
        return 'retired hurt'
    if dtype in ('RETIRED_NOT_OUT', 'RETIRED'):
        return 'retired not out'
    if dtype in ('TIMED_OUT', 'ABSENT'):
        return 'absent out'
    if dtype == 'HIT_BALL_TWICE':
        return f"hit ball twice b: {bowler or 'Unknown'}"

    print(f"Warning: unmapped dismissal type '{dtype}'")
    return dtype.lower().replace('_', ' ')


#########################################################################################################################
# main entry point
#########################################################################################################################

def build_match_info(game_summary, grade_name, our_club_regex=OUR_CLUB_REGEX, overwrite_md=False, our_team_id=None):
    """
    Takes the dict returned by PlayHQClient.get_game_summary() and writes the same
    innings_N_batting.md / innings_N_bowling.md / innings_N_fielding.md / match_info.md
    files that scrape_scorecard() writes, then returns match_info.
    overwrite_md=False will only write md files if they don't exist

    our_team_id: use this to disambiguate which team is "ours" when two of our own teams
    (e.g. Red vs Blue) play each other and both match our_club_regex. If not given, falls
    back to matching our_club_regex against the teams' names.
    """
    teams_by_id = {t['id']: t for t in game_summary['teams']}
    appearances_by_id = {a['id']: a for a in game_summary['appearances']}

    #########################################################################################################################
    # Match info
    #########################################################################################################################
    if our_team_id is not None:
        our_team = teams_by_id.get(our_team_id)
        if our_team is None:
            raise Exception(f"our_team_id {our_team_id} not found in teams: {[t['name'] for t in game_summary['teams']]}")
    else:
        matching_teams = [t for t in game_summary['teams'] if re.search(our_club_regex, t['name'])]
        if not matching_teams:
            raise Exception(f"Could not find our team in teams: {[t['name'] for t in game_summary['teams']]}")
        if len(matching_teams) > 1:
            raise Exception(
                f"Multiple teams match our_club_regex ({[t['name'] for t in matching_teams]}) - "
                f"pass our_team_id to disambiguate which one is ours"
            )
        our_team = matching_teams[0]
    opponent_team = next(t for t in game_summary['teams'] if t['id'] != our_team['id'])
    opponent = opponent_team['name']

    if our_team.get('outcome', '').startswith('WON'):
        mi_winner = our_team['name']
        mi_result = 'W1'
    elif opponent_team.get('outcome', '').startswith('WON'):
        mi_winner = opponent_team['name']
        mi_result = 'L1'
    else:
        mi_winner = 'draw'
        mi_result = 'D'

    round_name = game_summary['round']['name']
    if round_name.startswith('Round '):
        mi_round = round_name.replace('Round ', '').strip()
    elif 'Semi' in round_name:
        mi_round = 'SF'
    elif 'Grand Final' in round_name:
        mi_round = 'GF'
    else:
        mi_round = round_name

    playing_surfaces = {s['id']: s for s in game_summary.get('playingSurfaces', [])}
    schedule = game_summary['schedule']
    mi_num_days = len(schedule)

    surface = playing_surfaces.get(schedule[0]['playingSurfaceId'])
    mi_venue = f"{surface['venue']['name']} / {surface['name']}" if surface else ''
    tz = ZoneInfo(surface['venue']['timezone']) if surface else ZoneInfo('Australia/Adelaide')

    def local_date(sched_entry):
        dt = datetime.fromisoformat(sched_entry['dateTime'].replace('Z', '+00:00')).astimezone(tz)
        return f"{dt.day} {dt.strftime('%b %Y')}", dt

    mi_date_day_1, dt1 = local_date(schedule[0])
    mi_date_day_2 = local_date(schedule[1])[0] if mi_num_days > 1 else ''

    if dt1.month >= 9:
        mi_season = f"{dt1.year - 2000}-{dt1.year - 1999}"
    else:
        mi_season = f"{dt1.year - 2001}-{dt1.year - 2000}"

    mi_captain = 'none'
    for a in game_summary['appearances']:
        if a.get('teamId') == our_team['id'] and a.get('captainRole') == 'CAPTAIN':
            mi_captain = _appearance_name(a)
            break

    #########################################################################################################################
    # Create directories for markdown tables
    #########################################################################################################################
    # handles "Adelaide Bulldogs Red", "Adelaide Bulldogs Red U14" and "Adelaide Bulldogs (Red)"
    team_name_clean = re.sub(r'\s+U\d\d\s*$', '', our_team['name']).strip()
    team = next((c for c in ('Red', 'White', 'Blue', 'Royal')
                 if re.search(rf'[\s(\[]{c}[\s)\]]*$', team_name_clean, re.IGNORECASE)), None)

    if team is None:
        grade_dirname = grade_name.replace('/','')
    else:
        grade_dirname = grade_name.replace('/','')+' - '+team

    game_dir = f'data/{mi_season}/{grade_dirname}/Rnd_{mi_round}'

    # same junior test as wrangle_match_data; FOW and captain aren't recorded for juniors
    is_junior = bool(re.search(r'(Under|Junior|U\d)', grade_name))
    Path(game_dir).mkdir(parents=True, exist_ok=True)

    #########################################################################################################################
    # Innings
    #########################################################################################################################
    innings = []
    extras = []
    overs = []
    fow = []
    batting_counts = {}
    num_innings_played = 0

    for period in game_summary['periods']:
        batting_team = next((t for t in period['teams'] if t['discipline'] == 'BATTING'), None)
        bowling_team = next((t for t in period['teams'] if t['discipline'] == 'BOWLING'), None)

        if not batting_team or not batting_team.get('appearances'):
            print(f"Innings not played: {period.get('name')}")
            continue

        num_innings_played += 1
        ii = num_innings_played

        team_name = teams_by_id[batting_team['id']]['name']
        batting_counts[team_name] = batting_counts.get(team_name, 0) + 1
        ordinal = ORDINALS.get(batting_counts[team_name], f"{batting_counts[team_name]}th")
        innings.append(f"{team_name} {ordinal} Innings")

        #########################################################################################################################
        # Batting Scorecard
        #########################################################################################################################
        dismissals = _build_dismissal_map(period)
        batting_df = pd.DataFrame(columns=['batter', 'how_out', 'score', 'balls_faced', '_4s', '_6s'])
        batting_appearances = sorted(batting_team['appearances'], key=lambda a: a['displayOrder'])
        for i, app in enumerate(batting_appearances):
            name = _name_by_id(app['id'], appearances_by_id)
            how_out = _how_out_text(app.get('status'), dismissals.get(app['id']), appearances_by_id)
            score = _stat(app.get('statistics'), 'TOTAL_RUNS', 0)
            balls_faced = _stat(app.get('statistics'), 'BALLS_FACED', 0)
            fours = _stat(app.get('statistics'), 'FOURS', 0)
            sixes = _stat(app.get('statistics'), 'SIXES', 0)
            batting_df.loc[i] = [name, how_out, str(score), str(balls_faced), str(fours), str(sixes)]

        # players in the team's squad who aren't listed in the innings did not bat
        listed_ids = {app['id'] for app in batting_appearances}
        for app in game_summary['appearances']:
            if app.get('teamId') == batting_team['id'] and app['id'] not in listed_ids:
                batting_df.loc[len(batting_df)] = [_appearance_name(app), 'did not bat', '0', '0', '0', '0']

        if len(batting_df) == 0:
            batting_df.loc[0] = ['scorecard missing', 'did not bat', ' ', ' ', ' ', ' ']

        if overwrite_md or not os.path.exists(f'{game_dir}/innings_{ii}_batting.md'):
            with open(f'{game_dir}/innings_{ii}_batting.md', 'w') as f:
                f.write(batting_df.to_markdown())

        #########################################################################################################################
        # Fall of wickets
        #########################################################################################################################
        fall_of_wickets = batting_team.get('fallOfWickets')
        if fall_of_wickets:
            fow_str = ', '.join(
                f"{w['sequenceNo']}-{w['runs']} {_name_by_id(w['appearanceId'], appearances_by_id)}"
                for w in fall_of_wickets
            )
            fow.append([fow_str])
        else:
            if not is_junior:
                print(f'Missing FOW for innings {ii}')
            fow.append([])

        #########################################################################################################################
        # Extras / Overs
        #########################################################################################################################
        batting_stats = batting_team.get('statistics', [])
        extras.append({
            'wd': int(_stat(batting_stats, 'EXTRA_WIDES', 0)),
            'nb': int(_stat(batting_stats, 'EXTRA_NO_BALLS', 0)),
            'lb': int(_stat(batting_stats, 'EXTRA_LEG_BYES', 0)),
            'b': int(_stat(batting_stats, 'EXTRA_BYES', 0)),
            'p': int(_stat(batting_stats, 'EXTRA_PENALTY_RUNS', 0)),
        })
        overs.append(_format_overs(_stat(batting_stats, 'TOTAL_OVERS', 0)))

        #########################################################################################################################
        # Bowling Scorecard (and Fielding, from the same fielding-team appearances)
        #########################################################################################################################
        bowling_df = pd.DataFrame(columns=['bowler', 'overs', 'maidens', 'runs', 'wickets', 'wides', 'no_balls',
                                            '_4s_against', '_6s_against', 'highover', '_2nd_high_over'])
        fielding_df = pd.DataFrame(columns=['player', 'catches', 'run_outs', 'stumpings'])

        if bowling_team and bowling_team.get('appearances'):
            fielding_appearances = sorted(bowling_team['appearances'], key=lambda a: a['displayOrder'])
            bi = 0
            for app in fielding_appearances:
                name = _name_by_id(app['id'], appearances_by_id)
                stats = app.get('statistics') or []
                if _stat(stats, 'OVERS', None) is not None:
                    bowling_df.loc[bi] = [
                        name,
                        _format_overs(_stat(stats, 'OVERS', 0)),
                        _stat(stats, 'MAIDENS', 0),
                        _stat(stats, 'RUNS', 0),
                        _stat(stats, 'WICKETS', 0),
                        _stat(stats, 'WIDES', 0),
                        _stat(stats, 'NO_BALLS', 0),
                        0, 0, 0, 0,
                    ]
                    bi += 1

                catches = _stat(stats, 'TOTAL_CATCHES', None)
                if catches is None:
                    catches = int(_stat(stats, 'CATCHES_AS_FIELDER', 0)) + int(_stat(stats, 'CATCHES_AS_WICKET_KEEPER', 0))
                else:
                    catches = int(catches)
                run_outs = _stat(stats, 'TOTAL_RUN_OUTS', None)
                if run_outs is None:
                    run_outs = int(_stat(stats, 'RUN_OUTS_ASSISTED', 0)) + int(_stat(stats, 'RUN_OUTS_UNASSISTED', 0))
                else:
                    run_outs = int(run_outs)
                stumpings = int(_stat(stats, 'STUMPINGS', 0))
                if catches or run_outs or stumpings:
                    fielding_df.loc[len(fielding_df)] = [name, catches, run_outs, stumpings]

        if len(bowling_df) == 0:
            for bi in range(1, 7):
                bowling_df.loc[bi] = ['', '', '', '', '', '', '', '', '', '', '']
            print('empty bowling scorecard')

        if overwrite_md or not os.path.exists(f'{game_dir}/innings_{ii}_bowling.md'):
            with open(f'{game_dir}/innings_{ii}_bowling.md', 'w') as f:
                f.write(bowling_df.to_markdown())

        if len(fielding_df) == 0:
            print('empty fielding card')

        if overwrite_md or not os.path.exists(f'{game_dir}/innings_{ii}_fielding.md'):
            with open(f'{game_dir}/innings_{ii}_fielding.md', 'w') as f:
                f.write(fielding_df.to_markdown())

    #########################################################################################################################
    # match_info.md
    #########################################################################################################################
    match_info = {
        'season': mi_season,
        'grade': grade_dirname,
        'round': mi_round,
        'num_days': mi_num_days,
        'date_day_1': mi_date_day_1,
        'date_day_2': mi_date_day_2,
        'num_innings': num_innings_played,
        'innings_list': innings,
        'fow_list': fow,
        'extras': extras,
        'overs': overs,
        'venue': mi_venue,
        'opponent': opponent,
        'winner': mi_winner,
        'result': mi_result,
        'captain': mi_captain,
        'game_dir': game_dir,
    }

    if match_info['captain'] == 'none' and not is_junior:
        print('Missing Captain')
    for ii in range(len(match_info['extras'])):
        if match_info['extras'][ii] == {'wd': 0, 'nb': 0, 'lb': 0, 'b': 0, 'p': 0}:
            print(f'Missing extras for innings {ii + 1}')

    match_info_df = pd.DataFrame.from_dict(match_info, orient='index').to_markdown()
    if overwrite_md or not os.path.exists(f'{game_dir}/match_info.md'):
        with open(f'{game_dir}/match_info.md', 'w') as f:
            f.write(match_info_df)

    return match_info


def fetch_match(client, game_id, grade_name, our_club_regex=OUR_CLUB_REGEX, overwrite_md=False, our_team_id=None):
    """Fetch a single game from the API and write it out. Equivalent to scrape_scorecard(url, ...)."""
    game_summary = client.get_game_summary(game_id)
    return build_match_info(game_summary, grade_name, our_club_regex=our_club_regex, overwrite_md=overwrite_md,
                             our_team_id=our_team_id)


def _season_is_current(season, now):
    """True if the season is ACTIVE, or `now` falls between its startDate and endDate."""
    if season.get('status') == 'ACTIVE':
        return True
    start, end = season.get('startDate'), season.get('endDate')
    if not start or not end:
        return False
    parse = lambda s: datetime.fromisoformat(s.replace('Z', '+00:00'))
    return parse(start) <= now <= parse(end)


def find_grades_for_team(client, organisation_id=None, our_club_regex=OUR_CLUB_REGEX, current_only=False):
    """
    Searches every season/grade in an association for grades where a team matching
    our_club_regex (e.g. 'Adelaide Lutheran') is playing. If current_only, only
    seasons that are currently running are searched.

    Returns a list of dicts with season_id/name, association_id/name, competition_id/name,
    grade_id/name and the matching team's id/name. If a grade has more than one matching
    team (e.g. two of our sides in the same grade), one result is returned per team.
    """
    results = []
    now = datetime.now(ZoneInfo("UTC"))
    for season in client.get_seasons(organisation_id=organisation_id):
        if current_only and not _season_is_current(season, now):
            continue
        for grade in client.get_grades(season_id=season['id']):
            try:
                fixture = client.get_grade_fixture(grade_id=grade['id'])
            except Exception as e:
                print(f"Failed to fetch fixture for grade {grade['id']} ({grade['name']}): {e}")
                continue

            teams = [t for t in fixture.get('teams', []) if re.search(our_club_regex, t['name'])]
            if not teams:
                continue

            for team in teams:
                results.append({
                    'season_id': season['id'],
                    'season_name': season['name'],
                    'association_id': season.get('association', {}).get('id'),
                    'association_name': season.get('association', {}).get('name'),
                    'competition_id': season.get('competition', {}).get('id'),
                    'competition_name': season.get('competition', {}).get('name'),
                    'grade_id': grade['id'],
                    'grade_name': grade['name'],
                    'team_id': team['id'],
                    'team_name': team['name'],
                })
    return results


def _game_start(game):
    """Start datetime (tz-aware) of a fixture game, or None if the fixture has no schedule for it."""
    schedule = game.get('schedule') or []
    if not schedule or 'dateTime' not in schedule[0]:
        return None
    return datetime.fromisoformat(schedule[0]['dateTime'].replace('Z', '+00:00'))


def fetch_grade_matches(client, grade_id, grade_name, our_club_regex=OUR_CLUB_REGEX, overwrite_md=False, since=None):
    """
    Fetch every completed game in a grade's fixture and write them all out. If both teams
    in a game are our own (e.g. Red vs Blue), the game is written out twice - once from
    each team's perspective - so both teams' directories get the match.

    If since (a tz-aware datetime) is given, games that started before it are skipped.
    """
    fixture = client.get_grade_fixture(grade_id)
    fixture_teams_by_id = {t['id']: t for t in fixture.get('teams', [])}
    match_infos = []
    for round_ in fixture.get('rounds', []):
        for game in round_.get('games', []):
            if game['status'] != 'FINAL':
                continue
            if since is not None:
                start = _game_start(game)
                if start is not None and start < since:
                    continue

            our_team_ids = [
                t['id'] for t in game['teams']
                if re.search(our_club_regex, fixture_teams_by_id[t['id']]['name'])
            ]
            if not our_team_ids:
                continue  # not one of our games - nothing to fetch (and no error to report)
            if len(our_team_ids) > 1:
                for our_team_id in our_team_ids:
                    try:
                        match_infos.append(fetch_match(client, game['id'], grade_name,
                                                        our_club_regex=our_club_regex, overwrite_md=overwrite_md,
                                                        our_team_id=our_team_id))
                    except Exception as e:
                        print(f"Failed to fetch game {game['id']} for team {our_team_id}: {e}")
                continue

            try:
                match_infos.append(fetch_match(client, game['id'], grade_name,
                                                our_club_regex=our_club_regex, overwrite_md=overwrite_md))
            except Exception as e:
                print(f"Failed to fetch game {game['id']}: {e}")
    return match_infos


def list_associations(credentials_path=DEFAULT_CREDENTIALS_PATH):
    """Association keys in .api_credentials.yml (every `credentials_<x>` block that has a tenant)."""
    path = Path(credentials_path)
    if not path.exists():
        return []
    try:
        import yaml
        with open(path) as f:
            blocks = yaml.safe_load(f) or {}
    except ImportError:
        blocks = _parse_simple_yaml(path)
    return [k[len('credentials_'):] for k, v in blocks.items()
            if k.startswith('credentials_') and isinstance(v, dict) and v.get('tenant')]


def fetch_recent_matches(client, days, our_club_regex=OUR_CLUB_REGEX, overwrite_md=False, organisation_id=None):
    """
    Fetch all of our teams' completed games from the past `days` days, across every
    grade in the association's current season(s).
    """
    since = datetime.now(ZoneInfo('Australia/Adelaide')) - timedelta(days=days)
    grades = pd.DataFrame(find_grades_for_team(client, organisation_id=organisation_id,
                                               our_club_regex=our_club_regex, current_only=True))
    if grades.empty:
        return []

    match_infos = []
    for row in grades[['grade_id', 'grade_name']].drop_duplicates().itertuples(index=False):
        try:
            match_infos.extend(fetch_grade_matches(client, grade_id=row.grade_id, grade_name=row.grade_name,
                                                   our_club_regex=our_club_regex, overwrite_md=overwrite_md,
                                                   since=since))
        except Exception as e:
            print(f"Failed to fetch grade {row.grade_id} ({row.grade_name}): {e}")
    return match_infos


def fetch_recent_matches_all_associations(days=14, associations=None, our_club_regex=OUR_CLUB_REGEX, overwrite_md=False):
    """
    Run fetch_recent_matches for every association in .api_credentials.yml (or just the
    given list, e.g. ['asca', 'atca']) and return all the match_infos together.
    """
    match_infos = []
    for association in (associations or list_associations()):
        try:
            client = PlayHQClient(association=association)
            print(f"[{association}] organisation_id={client.organisation_id}, tenant={client.tenant}")
            found = fetch_recent_matches(client, days, our_club_regex=our_club_regex, overwrite_md=overwrite_md)
            for mi in found:
                print(f"[{association}] {mi['grade']} | Round {mi['round']} | {mi['date_day_1']}")
            print(f"[{association}] fetched {len(found)} match(es)")
            match_infos.extend(found)
        except Exception as e:
            print(f"[{association}] failed: {e}")
    return match_infos
