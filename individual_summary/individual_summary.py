import pandas as pd
import re
import math
from sqlalchemy import create_engine
from sqlalchemy import select
from sqlalchemy import text

engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')
pgconn = engine.connect()
