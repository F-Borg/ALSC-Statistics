"""
One-off cleanup of 3 junk rows found while adding a primary key to `batting`
(see add_primary_keys.py):
  - inningsid 1797: a completely empty placeholder row (no player, no score)
  - inningsid 1876, playerid 491: an exact duplicate row - delete one copy
  - inningsid 1695, playerid 0: two rows at batting_position 12/13, past the
    11-player batting order, with an unresolved playerid (0 isn't a real
    player or a sentinel) - both are junk
"""
from sqlalchemy import text
from python_scripts.db import get_engine

engine = get_engine()

with engine.begin() as conn:
    conn.execute(text("delete from batting where inningsid = 1797 and playerid is null"))

    conn.execute(text("""
        delete from batting where ctid in (
            select ctid from batting
            where inningsid = 1876 and playerid = 491
            order by ctid limit 1
        )
        """))

    conn.execute(text("delete from batting where inningsid = 1695 and playerid = 0 and batting_position in (12, 13)"))

print('Done.')
