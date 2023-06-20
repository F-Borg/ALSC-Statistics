import psycopg2





conn = psycopg2.connect(
    host="localhost",
    database="dev",
    user="postgres",
    password="postgres123"
    )

cur = conn.cursor()


cur.execute(        """
        CREATE TABLE vendors (
            vendor_id SERIAL PRIMARY KEY,
            vendor_name VARCHAR(255) NOT NULL
        )
        """)

cur.execute("select * from vendors")
cur.close()
conn.commit()
conn.close()


