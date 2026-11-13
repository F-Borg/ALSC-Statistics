"""Back up the Postgres statistics database with pg_dump (custom format), rotate old
dumps, and optionally upload the new one to Google Drive.

Usage (from repo root):
    python -m python_scripts.backup_postgres [--keep 10] [--no-drive] [--out-dir backups]

Restore:
    pg_restore -U postgres -d <dbname> --clean --if-exists backups/alsc_YYYY-MM-DD_HHMM.dump

Connection details come from python_scripts/db.py (PG* env vars / .api_credentials.yml).
"""
import argparse
import glob
import os
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path

from python_scripts.db import get_engine

REPO_ROOT = Path(__file__).resolve().parent.parent
DRIVE_BACKUP_FOLDER = "ALSC-Statistics-DB-Backups"


def find_pg_dump() -> str:
    # pg_dump must be >= the server version, so prefer the newest installed copy
    # (several versions can be installed side by side and PATH may point at an older one).
    candidates = sorted(
        glob.glob(r"C:\Program Files\PostgreSQL\*\bin\pg_dump.exe"),
        key=lambda p: int(Path(p).parents[1].name) if Path(p).parents[1].name.isdigit() else 0,
        reverse=True,
    )
    if candidates:
        return candidates[0]
    exe = shutil.which("pg_dump")
    if exe:
        return exe
    sys.exit("pg_dump not found. Add the PostgreSQL bin folder to PATH.")


def run_dump(out_dir: Path) -> Path:
    url = get_engine().url
    out_dir.mkdir(parents=True, exist_ok=True)
    out_file = out_dir / f"alsc_{datetime.now():%Y-%m-%d_%H%M}.dump"
    cmd = [
        find_pg_dump(),
        "-h", str(url.host), "-p", str(url.port), "-U", url.username, "-d", url.database,
        "-Fc", "-f", str(out_file),
    ]
    env = {**os.environ, "PGPASSWORD": url.password}  # via env so it isn't visible in the process list
    try:
        subprocess.run(cmd, env=env, check=True)
    except subprocess.CalledProcessError:
        out_file.unlink(missing_ok=True)  # don't leave a partial dump behind
        raise
    print(f"Wrote {out_file} ({out_file.stat().st_size / 1e6:.1f} MB)")
    return out_file


def rotate_local(out_dir: Path, keep: int):
    dumps = sorted(out_dir.glob("alsc_*.dump"))  # timestamped names sort chronologically
    for old in dumps[:-keep] if keep > 0 else []:
        old.unlink()
        print(f"Deleted old backup {old.name}")


def upload_to_drive(dump: Path, keep: int):
    from python_scripts.drive_upload import get_drive_service, get_or_create_folder, _upsert_file

    service = get_drive_service()
    folder = get_or_create_folder(service, DRIVE_BACKUP_FOLDER)
    _upsert_file(service, dump, folder, "application/octet-stream")
    print(f"Uploaded {dump.name} to Drive folder '{DRIVE_BACKUP_FOLDER}'")

    files = service.files().list(
        q=f"'{folder}' in parents and trashed=false and name contains 'alsc_'",
        fields="files(id, name)", pageSize=1000,
    ).execute()["files"]
    files.sort(key=lambda f: f["name"])
    for old in files[:-keep] if keep > 0 else []:
        service.files().delete(fileId=old["id"]).execute()
        print(f"Deleted old Drive backup {old['name']}")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--out-dir", default=str(REPO_ROOT / "backups"))
    ap.add_argument("--keep", type=int, default=10, help="how many dumps to keep (local and Drive)")
    ap.add_argument("--no-drive", action="store_true", help="skip the Google Drive upload")
    args = ap.parse_args()

    out_dir = Path(args.out_dir)
    dump = run_dump(out_dir)
    rotate_local(out_dir, args.keep)
    if not args.no_drive:
        upload_to_drive(dump, args.keep)
