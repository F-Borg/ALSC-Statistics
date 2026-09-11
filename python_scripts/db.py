"""
Builds the SQLAlchemy engine used to connect to the local Postgres statistics
database, without hardcoding the password in source.

Connection details are resolved in order: PG* env vars, then a
`credentials_postgres:` block in .api_credentials.yml (same file/format
api_playhq.py uses for PlayHQ credentials - see _load_credentials there).
"""
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

from python_scripts.api_playhq import _load_credentials, DEFAULT_CREDENTIALS_PATH

import os

_DEFAULTS = {'host': 'localhost', 'port': '5432', 'dbname': 'dev', 'user': 'postgres'}


def get_engine(credentials_path=DEFAULT_CREDENTIALS_PATH):
    creds = _load_credentials(credentials_path, association='postgres')

    password = os.environ.get('PGPASSWORD') or creds.get('password')
    if not password:
        raise Exception(
            'No Postgres password found (set PGPASSWORD env var, or add a '
            "'password:' entry to the credentials_postgres: block in "
            f'{credentials_path})'
        )

    url = URL.create(
        'postgresql+psycopg2',
        username=os.environ.get('PGUSER') or creds.get('user') or _DEFAULTS['user'],
        password=password,
        host=os.environ.get('PGHOST') or creds.get('host') or _DEFAULTS['host'],
        port=os.environ.get('PGPORT') or creds.get('port') or _DEFAULTS['port'],
        database=os.environ.get('PGDATABASE') or creds.get('dbname') or _DEFAULTS['dbname'],
    )
    return create_engine(url)
