
# https://github.com/blue-yonder/sqlalchemy_exasol

from sqlalchemy import create_engine
e = create_engine("exa+pyodbc://sys:exasol@VIACC")
r = e.execute("select 42 from dual").fetchall()

print(r)

e.dispose()

