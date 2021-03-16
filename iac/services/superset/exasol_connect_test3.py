
# https://github.com/blue-yonder/sqlalchemy_exasol

from sqlalchemy import create_engine
e = create_engine("exa+pyodbc://sys:exasol@EXAODBC/business_rules")
r = e.execute("select * from SYS.CAT" ).fetchall()


print(r)

e.dispose()

