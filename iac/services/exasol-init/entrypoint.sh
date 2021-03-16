#!/bin/bash
`dirname $0`/exa_install.sh exasol:8888 exasol-fs:8889 dev && /dvb_sql/create_db.sh exasol:8888 sys exasol 
