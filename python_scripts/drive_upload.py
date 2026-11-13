"""Upload .md files for recent games under data/ to Google Drive.

Usage:
    python python_scripts/drive_upload.py --days 14 [--folder-id <drive folder id>]

Setup: see admin notes. Needs credentials.json (OAuth desktop client) in the repo root;
token.json is created on first run. Both are gitignored.
"""
import argparse
import ast
import re
from datetime import datetime, timedelta
from pathlib import Path

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

REPO_ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = REPO_ROOT / "data"
SCOPES = ["https://www.googleapis.com/auth/drive.file"]  # only files this app creates


def _q(s: str) -> str:
    """Escape a string for use inside a Drive query literal."""
    return s.replace("\\", "\\\\").replace("'", "\\'")


def get_drive_service(creds_file="credentials.json", token_file="token.json"):
    creds_file, token_file = REPO_ROOT / creds_file, REPO_ROOT / token_file
    creds = None
    if token_file.exists():
        creds = Credentials.from_authorized_user_file(str(token_file), SCOPES)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            creds = InstalledAppFlow.from_client_secrets_file(str(creds_file), SCOPES).run_local_server(port=0)
        token_file.write_text(creds.to_json())
    return build("drive", "v3", credentials=creds)


def game_date(game_dir: Path):
    """Last day of the game, read from match_info.md (None if unavailable)."""
    text = (game_dir / "match_info.md").read_text(encoding="utf-8", errors="replace")
    return parse_game_date(text, game_dir)


def parse_game_date(text: str, label=""):
    """Last day of the game from match_info.md text (None if unavailable)."""
    game_dir = label
    dates = []
    for key in ("date_day_1", "date_day_2"):
        m = re.search(rf"\|\s*{key}\s*\|\s*([^|]*?)\s*\|", text)
        if m and m.group(1):
            try:
                dates.append(datetime.strptime(m.group(1), "%d %b %Y").date())
            except ValueError:
                print(f"Unparseable date in {game_dir}: {m.group(1)!r}")
    return max(dates) if dates else None


def recent_game_dirs(days: int):
    cutoff = (datetime.now() - timedelta(days=days)).date()
    for info in sorted(DATA_DIR.glob("*/*/Rnd_*/match_info.md")):
        d = game_date(info.parent)
        if d and d >= cutoff:
            yield info.parent


def get_or_create_folder(service, name, parent_id=None):
    q = f"name='{_q(name)}' and mimeType='application/vnd.google-apps.folder' and trashed=false"
    if parent_id:
        q += f" and '{parent_id}' in parents"
    files = service.files().list(q=q, fields="files(id)").execute()["files"]
    if files:
        return files[0]["id"]
    meta = {"name": name, "mimeType": "application/vnd.google-apps.folder"}
    if parent_id:
        meta["parents"] = [parent_id]
    return service.files().create(body=meta, fields="id").execute()["id"]


def _upsert_file(service, path: Path, parent_id, mimetype):
    """Create the file in the Drive folder, or overwrite it if the name already exists."""
    existing = service.files().list(
        q=f"name='{_q(path.name)}' and '{parent_id}' in parents and trashed=false",
        fields="files(id)",
    ).execute()["files"]
    media = MediaFileUpload(str(path), mimetype=mimetype)
    if existing:  # overwrite on re-run instead of duplicating
        service.files().update(fileId=existing[0]["id"], media_body=media).execute()
    else:
        service.files().create(body={"name": path.name, "parents": [parent_id]}, media_body=media).execute()


FILL_IN_FILE = DATA_DIR / "fill-ins.txt"
OUR_TEAM_PREFIX = "Adelaide Lutheran"  # also matches "Adelaide Lutheran II", "(White)" etc.


def _info_field(text: str, key: str):
    m = re.search(rf"^\|\s*{key}\s*\|\s*(.*?)\s*\|\s*$", text, re.M)
    return m.group(1) if m else ""


def _count_fill_in_batters(batting_md: Path) -> int:
    n = 0
    for line in batting_md.read_text(encoding="utf-8", errors="replace").splitlines():
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) > 1 and re.match(r"(Fill-in|Private player)", cells[1]):
            n += 1
    return n


def write_fill_in_report(path: Path = FILL_IN_FILE, min_fill_ins: int = 2, days=None) -> int:
    """List games where our team had `min_fill_ins`+ fill-in batters (only games from the
    last `days` days if given). Returns number of games listed."""
    cutoff = (datetime.now() - timedelta(days=days)).date() if days is not None else None
    rows = []
    for info in DATA_DIR.glob("*/*/Rnd_*/match_info.md"):
        game_dir = info.parent
        text = info.read_text(encoding="utf-8", errors="replace")
        if cutoff is not None:
            gd = parse_game_date(text, game_dir)
            if gd is None or gd < cutoff:
                continue
        try:
            innings = ast.literal_eval(_info_field(text, "innings_list"))
        except (ValueError, SyntaxError):
            continue
        for i, name in enumerate(innings, start=1):
            if not name.startswith(OUR_TEAM_PREFIX):
                continue
            batting = game_dir / f"innings_{i}_batting.md"
            if not batting.exists():
                continue
            count = _count_fill_in_batters(batting)
            if count >= min_fill_ins:
                d = parse_game_date(text, game_dir)
                rows.append((d or datetime.min.date(), game_dir, _info_field(text, "opponent"), count))
    rows.sort(key=lambda r: (r[0], str(r[1])))
    lines = [
        f"Games where {OUR_TEAM_PREFIX} had {min_fill_ins}+ fill-in batters"
        + (f" (last {days} days)" if days is not None else ""),
        f"Generated {datetime.now():%Y-%m-%d}; {len(rows)} games",
        "",
    ]
    for d, game_dir, opp, count in rows:
        season, grade, rnd = game_dir.relative_to(DATA_DIR).parts
        date_s = d.isoformat() if d != datetime.min.date() else "unknown date"
        lines.append(f"{date_s} | {season} | {grade} | {rnd.replace('_', ' ')} | vs {opp} | {count} fill-ins")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return len(rows)


def upload_recent_games(days: int, root_folder_id=None, root_name="ALSC-Statistics"):
    """Upload *.md of games played in the last `days` days, mirroring data/ on Drive.

    Also regenerates data/fill-ins.txt (same `days` window) and uploads it to the Drive root,
    and uploads each data/<season>/regular-fill-ins.txt to the matching season folder.
    """
    service = get_drive_service()
    root = root_folder_id or get_or_create_folder(service, root_name)
    n = 0
    for game_dir in recent_game_dirs(days):
        parent = root
        for part in game_dir.relative_to(DATA_DIR).parts:
            parent = get_or_create_folder(service, part, parent)
        for md in sorted(game_dir.glob("*.md")):
            _upsert_file(service, md, parent, "text/markdown")
            n += 1
        print(f"Uploaded {game_dir.relative_to(DATA_DIR)}")
    games = write_fill_in_report(days=days)
    _upsert_file(service, FILL_IN_FILE, root, "text/plain")
    # data/<season>/regular-fill-ins.txt -> ALSC-Statistics/<season>/regular-fill-ins.txt
    for reg in sorted(DATA_DIR.glob("*/regular-fill-ins.txt")):
        season_folder = get_or_create_folder(service, reg.parent.name, root)
        _upsert_file(service, reg, season_folder, "text/plain")
        print(f"Uploaded {reg.relative_to(DATA_DIR)}")
    print(f"Done: {n} files + fill-ins.txt ({games} games)")


FOLDER_MIME = "application/vnd.google-apps.folder"


def _list_children(service, folder_id):
    items, token = [], None
    while True:
        res = service.files().list(
            q=f"'{folder_id}' in parents and trashed=false",
            fields="nextPageToken, files(id, name, mimeType)",
            pageSize=1000,
            pageToken=token,
        ).execute()
        items += res["files"]
        token = res.get("nextPageToken")
        if not token:
            return items


def download_games(days=None, root_folder_id=None, root_name="ALSC-Statistics"):
    """Download .md files under the Drive root into data/, overwriting local copies.

    Drive layout mirrors data/<season>/<grade>/Rnd_N/, so files land at the same paths.
    If `days` is given, only games played in the last `days` days are downloaded
    (date read from each game folder's match_info.md on Drive).
    """
    service = get_drive_service()
    root = root_folder_id or get_or_create_folder(service, root_name)
    data_root = DATA_DIR.resolve()
    cutoff = (datetime.now() - timedelta(days=days)).date() if days is not None else None
    n = 0

    def walk(folder_id, local_dir):
        nonlocal n
        children = _list_children(service, folder_id)
        info = next((c for c in children if c["name"] == "match_info.md"), None)
        if cutoff is not None and info:  # this is a game folder: check its date
            text = service.files().get_media(fileId=info["id"]).execute().decode("utf-8", errors="replace")
            d = parse_game_date(text, local_dir)
            if d is None or d < cutoff:
                return
        for item in children:
            target = (local_dir / item["name"]).resolve()
            if data_root not in target.parents:  # guard against odd names escaping data/
                print(f"Skipping suspicious name: {item['name']!r}")
                continue
            if item["mimeType"] == FOLDER_MIME:
                walk(item["id"], target)
            elif item["name"].endswith(".md"):
                target.parent.mkdir(parents=True, exist_ok=True)
                content = service.files().get_media(fileId=item["id"]).execute()
                target.write_bytes(content)
                n += 1

    walk(root, data_root)
    print(f"Downloaded {n} files")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--download", action="store_true", help="download from Drive into data/ (overwrites local)")
    ap.add_argument("--days", type=int, default=None,
                    help="only games within the last N days (upload default: 14; download default: all)")
    ap.add_argument("--folder-id", default=None, help="Drive folder id to upload into / download from")
    args = ap.parse_args()
    if args.download:
        download_games(args.days, args.folder_id)
    else:
        upload_recent_games(args.days if args.days is not None else 14, args.folder_id)
