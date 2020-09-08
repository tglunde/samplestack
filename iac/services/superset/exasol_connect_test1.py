
# https://github.com/blue-yonder/sqlalchemy_exasol

from sqlalchemy import create_engine
e = create_engine("exa+pyodbc://sys:exasol@172.105.76.56:8888/exa_statistics?CONNECTIONLCALL=en_US.UTF-8&driver=EXAODBC")
r = e.execute("select 42 from dual").fetchall()

print(r)

e.dispose()

