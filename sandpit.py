from sqlalchemy import create_engine
from sqlalchemy import select
from sqlalchemy import text

engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')

pgconn = engine.connect()


test = pgconn.execute(text('select * from seasons limit 10')).fetchall()







