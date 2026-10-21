"""
Adds primary key constraints to the existing stats tables (senior, junior '_j'
and inclusive '_i' variants).

Run with APPLY = False first (the default) to see a report of any NULL /
duplicate-key violations that would stop the constraint being added. Fix
those (see wrangle_match_data.py / utility.check_player_ids for how missing
playerids happen), then re-run with APPLY = True to actually add the keys.
Tables that already have a primary key, or that still have violations, are
skipped and listed at the end - it's safe to re-run.
"""
from sqlalchemy import text
from python_scripts.db import get_engine

engine = get_engine()

APPLY = True  # set True to actually add the constraints once the report is clean

# table -> primary key column(s)
PK_SPECS = {
    'matches':   ['matchid'],
    'matches_j': ['matchid'],
    'matches_i': ['matchid'],

    'innings':   ['inningsid'],
    'innings_j': ['inningsid'],
    'innings_i': ['inningsid'],

    'players':   ['playerid'],
    'seasons':   ['seasonid'],
    'seasons_j': ['seasonid'],
    'seasons_i': ['seasonid'],

    'batting':   ['inningsid', 'playerid'],
    'batting_j': ['inningsid', 'playerid'],
    'batting_i': ['inningsid', 'playerid'],

    'bowling':   ['inningsid', 'playerid'],
    'bowling_j': ['inningsid', 'playerid'],
    'bowling_i': ['inningsid', 'playerid'],

    'fielding_j': ['inningsid', 'playerid'],
    'fielding_i': ['inningsid', 'playerid'],

    'wickets':   ['inningsid', 'batting_position'],
    'wickets_j': ['inningsid', 'batting_position'],
    'wickets_i': ['inningsid', 'batting_position'],
}


def table_exists(conn, table):
    return conn.execute(
        text("select 1 from information_schema.tables where table_schema = 'public' and table_name = :t"),
        {'t': table},
    ).first() is not None


def has_primary_key(conn, table):
    return conn.execute(
        text("""
            select 1 from information_schema.table_constraints
            where table_schema = 'public' and table_name = :t and constraint_type = 'PRIMARY KEY'
            """),
        {'t': table},
    ).first() is not None


def find_violations(conn, table, cols):
    """Returns (null_rows, duplicate_groups) for the given candidate key."""
    col_list = ', '.join(cols)
    null_where = ' or '.join(f'{c} is null' for c in cols)

    null_rows = conn.execute(text(f'select count(*) from {table} where {null_where}')).scalar()
    duplicate_groups = conn.execute(text(f"""
        select count(*) from (
            select {col_list} from {table}
            where not ({null_where})
            group by {col_list}
            having count(*) > 1
        ) dupes
        """)).scalar()
    return null_rows, duplicate_groups


def main():
    skipped = []
    with engine.begin() as conn:
        for table, cols in PK_SPECS.items():
            if not table_exists(conn, table):
                continue

            if has_primary_key(conn, table):
                print(f'{table}: already has a primary key, skipping')
                continue

            null_rows, duplicate_groups = find_violations(conn, table, cols)
            key_desc = ', '.join(cols)

            if null_rows or duplicate_groups:
                print(f'{table} ({key_desc}): {null_rows} row(s) with a NULL key column, '
                      f'{duplicate_groups} duplicate key group(s) - NOT adding constraint')
                skipped.append(table)
                continue

            print(f'{table} ({key_desc}): clean')
            if APPLY:
                conn.execute(text(f'alter table {table} add primary key ({key_desc})'))
                print(f'{table}: primary key added')

    if not APPLY:
        print('\nAPPLY is False - no constraints were added. Re-run with APPLY = True once the report above is clean.')
    if skipped:
        print(f'\nSkipped (need cleanup first): {skipped}')


if __name__ == '__main__':
    main()
