"""
The junior tables (batting_j / bowling_j / fielding_j) record an unnamed
fill-in player as playerid = -99 ('Unknown PlayerX' in `players`). When two
different fill-ins bat/bowl/field in the same innings, they collide on that
same id, which breaks a (inningsid, playerid) primary key.

Fix: renumber every -99 row to -(100 - <position within the innings>), so a
lone fill-in at position 1 keeps the familiar -99, and a second/third fill-in
in the same innings gets a distinct -98/-97/etc instead of colliding. Each
new id gets its own 'Player<N>' row in `players` (e.g. -98 -> 'Unknown
Player-98') so the name still tells you which synthetic id it is - the
original -99 row is renamed to 'Unknown Player-99' for the same reason.
batting_j has a real batting_position column to use as the position;
bowling_j and fielding_j don't store an order, so row order within the
innings (by ctid, i.e. insertion order) is used instead.

Run with APPLY = False first to preview what would change (no writes), then
APPLY = True to actually run it. Safe to re-run: once no playerid is -99,
there's nothing left to renumber.
"""
import pandas as pd
from sqlalchemy import text
from python_scripts.db import get_engine

engine = get_engine()

APPLY = True


def sentinel_player(new_id):
    return {'player_name': f'Player{new_id}, Unknown', 'firstname': 'Unknown', 'surname': f'Player{new_id}', 'name_fl': f'Unknown Player{new_id}'}


# table -> SQL expression for "position within the innings", 1-based
POSITION_EXPR = {
    'batting_j': 'batting_position',
    'bowling_j': 'row_number() over (partition by inningsid order by ctid)',
    'fielding_j': 'row_number() over (partition by inningsid order by ctid)',
}


def preview(conn, table, position_expr):
    return pd.read_sql(f"""
        select inningsid, playerid, {position_expr} as position,
               -(100 - {position_expr}) as new_playerid
        from {table}
        where playerid = -99
        order by inningsid
        """, con=conn)


def main():
    with engine.begin() as conn:
        all_new_ids = set()
        previews = {}
        for table, position_expr in POSITION_EXPR.items():
            df = preview(conn, table, position_expr)
            previews[table] = df
            print(f'--- {table}: {len(df)} row(s) to renumber ---')
            print(df)
            all_new_ids.update(int(x) for x in df['new_playerid'].unique())

        if not APPLY:
            print(f'\nAPPLY is False - no changes made. New sentinel ids that would be created: {sorted(all_new_ids)}')
            return

        # rename the existing -99 row, and add a players row for every other new sentinel id
        # (no ON CONFLICT - players has no unique constraint on playerid yet)
        conn.execute(text("""
            update players set player_name = :player_name, firstname = :firstname, surname = :surname, name_fl = :name_fl
            where playerid = -99
            """), sentinel_player(-99))

        for new_id in sorted(all_new_ids):
            if new_id == -99:
                continue
            exists = conn.execute(text('select 1 from players where playerid = :playerid'), {'playerid': new_id}).first()
            if exists:
                continue
            conn.execute(text("""
                insert into players (playerid, player_name, firstname, surname, dob, name_fl)
                values (:playerid, :player_name, :firstname, :surname, NULL, :name_fl)
                """), {'playerid': new_id, **sentinel_player(new_id)})

        for table, position_expr in POSITION_EXPR.items():
            conn.execute(text(f"""
                update {table} t
                set playerid = -(100 - sub.position)
                from (
                    select inningsid, playerid, ctid, {position_expr} as position
                    from {table}
                    where playerid = -99
                ) sub
                where t.inningsid = sub.inningsid and t.ctid = sub.ctid and t.playerid = -99
                """))
            print(f'{table}: updated')

    print('\nDone.')


if __name__ == '__main__':
    main()
