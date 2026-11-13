"""Replace "Fill-in" with a regular player's name for Adelaide Lutheran, per grade.

Reads data/<season>/regular-fill-ins.txt, one line per grade:
    "<grade directory name>" "<player name>"

For every game in that grade where Adelaide Lutheran has exactly ONE fill-in listed in its
batting innings, the fill-in is replaced with the player's name in:
  - Lutheran's batting file(s)                       (batter column)
  - Lutheran's bowling / fielding files              (innings the opponent batted)
  - the opponent's batting how_out text              (e.g. "c: Fill-in b: Fill-in")
  - match_info.md fow_list for Lutheran's innings

Bowling/fielding/how_out are only touched when Lutheran has at most one fill-in row in
bowling and in fielding (otherwise it is ambiguous who is who) - those games are reported.

Dry run by default; pass --apply to write the files. data/ is gitignored, so there is no
git history to undo an applied run.

Usage:
    py python_scripts/replace_regular_fill_ins.py [--season 26-27] [--days 14] [--apply]
"""
import argparse
import ast
import re
import sys
from datetime import datetime, timedelta
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = REPO_ROOT / "data"
OUR_TEAM_PREFIX = "Adelaide Lutheran"
FILL_IN = re.compile(r"\bFill-in\b")
FILL_IN_NAME = re.compile(r"(Fill-in|Private player)")


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def read_regulars(path: Path) -> list[tuple[str, str]]:
    out = []
    for line in read(path).splitlines():
        if not line.strip():
            continue
        parts = re.findall(r'"([^"]*)"', line)
        if len(parts) != 2:
            print(f"  ! {path}: cannot parse line {line!r}")
            continue
        out.append((parts[0], parts[1]))
    return out


def info_field(text: str, key: str) -> str:
    m = re.search(rf"^\|\s*{key}\s*\|\s*(.*?)\s*\|\s*$", text, re.M)
    return m.group(1) if m else ""


def table_rows(text: str):
    """Yield (line_idx, cells) for body rows of a pandas markdown table (cells keep padding)."""
    lines = text.split("\n")
    for i, line in enumerate(lines):
        if i < 2 or not line.startswith("|"):
            continue
        yield i, lines, line.split("|")


def fill_in_name_rows(text: str) -> int:
    """Number of body rows whose name column (2nd) is a fill-in."""
    return sum(1 for _, _, cells in table_rows(text) if len(cells) > 2 and FILL_IN_NAME.match(cells[2].strip()))


def repad(old_cell: str, new_content: str) -> str:
    """Put new_content in a cell, keeping the old cell width when it fits."""
    width = len(old_cell)
    body = " " + new_content
    return body.ljust(width) if len(body) < width else body + " "


def replace_name_column(text: str, name: str):
    """Replace fill-in names in the name column (2nd). Returns (new_text, count)."""
    n = 0
    for i, lines, cells in table_rows(text):
        if len(cells) > 2 and FILL_IN_NAME.match(cells[2].strip()):
            cells[2] = repad(cells[2], name)
            lines[i] = "|".join(cells)
            n += 1
    return "\n".join(lines) if n else text, n


def replace_how_out(text: str, name: str):
    """Replace Fill-in in the how_out column (3rd) of a batting table."""
    n = 0
    out = text.split("\n")
    for i, lines, cells in table_rows(text):
        if len(cells) > 3 and FILL_IN.search(cells[3]):
            cells[3] = repad(cells[3], FILL_IN.sub(name, cells[3].strip()))
            out[i] = "|".join(cells)
            n += 1
    return "\n".join(out), n


def replace_fow(info_text: str, lutheran_idx: set[int], name: str):
    """Replace Fill-in in the fow_list sublists belonging to Lutheran's innings."""
    m = re.search(r"^(\|\s*fow_list\s*\|)( .*? )(\|)\s*$", info_text, re.M)
    if not m:
        return info_text, 0
    try:
        fow = ast.literal_eval(m.group(2).strip())
    except (ValueError, SyntaxError):
        return info_text, 0
    n = 0
    for idx in lutheran_idx:
        if idx < len(fow):
            new = [FILL_IN.sub(name, s) for s in fow[idx]]
            n += sum(a != b for a, b in zip(fow[idx], new))
            fow[idx] = new
    if not n:
        return info_text, 0
    cell = repad(m.group(2), repr(fow))
    return info_text[: m.start()] + m.group(1) + cell + m.group(3) + info_text[m.end():], n


def game_date(info_text: str):
    """Last day of the game from match_info.md text (None if unavailable)."""
    dates = []
    for key in ("date_day_1", "date_day_2"):
        v = info_field(info_text, key)
        if v:
            try:
                dates.append(datetime.strptime(v, "%d %b %Y").date())
            except ValueError:
                pass
    return max(dates) if dates else None


def process_game(game_dir: Path, name: str, apply: bool, cutoff=None) -> str:
    info_path = game_dir / "match_info.md"
    if not info_path.exists():
        return "no match_info.md"
    info = read(info_path)
    if cutoff is not None:
        d = game_date(info)
        if d is None or d < cutoff:
            return f"skipped (game date {d or 'unknown'} before {cutoff})"
    try:
        innings = ast.literal_eval(info_field(info, "innings_list"))
    except (ValueError, SyntaxError):
        return "bad innings_list"
    ours = {i for i, t in enumerate(innings) if t.startswith(OUR_TEAM_PREFIX)}
    theirs = set(range(len(innings))) - ours
    if not ours:
        return "Lutheran not in innings_list"

    def f(kind, i):  # file for innings index i (0-based)
        return game_dir / f"innings_{i + 1}_{kind}.md"

    # only act if exactly one Lutheran fill-in across our batting innings
    batting = {i: read(f("batting", i)) for i in ours if f("batting", i).exists()}
    n_bat = sum(fill_in_name_rows(t) for t in batting.values())
    if n_bat != 1:
        return f"skipped ({n_bat} Lutheran fill-in batters)"

    changes = {}  # path -> new text
    notes = []
    for i, t in batting.items():
        new, n = replace_name_column(t, name)
        if n:
            changes[f("batting", i)] = new

    # bowling / fielding / how_out / fow only if unambiguous
    bowl = {i: read(f("bowling", i)) for i in theirs if f("bowling", i).exists()}
    field = {i: read(f("fielding", i)) for i in theirs if f("fielding", i).exists()}
    n_bowl = sum(fill_in_name_rows(t) for t in bowl.values())
    n_field = sum(fill_in_name_rows(t) for t in field.values())
    if n_bowl <= 1 and n_field <= 1:
        for i, t in bowl.items():
            new, n = replace_name_column(t, name)
            if n:
                changes[f("bowling", i)] = new
        for i, t in field.items():
            new, n = replace_name_column(t, name)
            if n:
                changes[f("fielding", i)] = new
        for i in theirs:
            if f("batting", i).exists():
                t = read(f("batting", i))
                new, n = replace_how_out(t, name)
                if n:
                    changes[f("batting", i)] = new
        new_info, n = replace_fow(info, ours, name)
        if n:
            changes[info_path] = new_info
    else:
        notes.append(f"bowling/fielding/how_out/fow left alone ({n_bowl} bowling, {n_field} fielding fill-in rows)")

    if apply:
        for p, text in changes.items():
            p.write_text(text, encoding="utf-8", newline="")
    names = ", ".join(sorted(p.name for p in changes))
    return f"{'replaced' if apply else 'would replace'} in: {names}" + ("; " + "; ".join(notes) if notes else "")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--season", default=None, help="only this season dir, e.g. 26-27 (default: all)")
    ap.add_argument("--apply", action="store_true", help="write changes (default is a dry run)")
    ap.add_argument("--days", type=int, default=None, help="only games played in the last N days (default: all)")
    args = ap.parse_args()
    cutoff = (datetime.now() - timedelta(days=args.days)).date() if args.days is not None else None

    files = sorted(DATA_DIR.glob(f"{args.season or '*'}/regular-fill-ins.txt"))
    if not files:
        sys.exit("No regular-fill-ins.txt found")
    for reg_file in files:
        season_dir = reg_file.parent
        print(f"{season_dir.name}:")
        for grade, name in read_regulars(reg_file):
            grade_dir = season_dir / grade
            if not grade_dir.is_dir():
                print(f"  ! grade folder not found: {grade!r}")
                continue
            print(f"  {grade} -> {name}")
            for game_dir in sorted(grade_dir.glob("Rnd_*"), key=lambda p: int(re.sub(r"\D", "", p.name) or 0)):
                print(f"    {game_dir.name}: {process_game(game_dir, name, args.apply, cutoff)}")
    if not args.apply:
        print("\nDry run only - re-run with --apply to write changes.")


if __name__ == "__main__":
    main()
