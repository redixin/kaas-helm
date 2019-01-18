{{- define "wtf" }}
#!/usr/bin/env python

# Creates db and user for an OpenStack Service:
# Set ROOT_DB_CONNECTION and DB_CONNECTION environment variables to contain
# SQLAlchemy strings for the root connection to the database and the one you
# wish the service to use. Alternatively, you can use an ini formatted config
# at the location specified by OPENSTACK_CONFIG_FILE, and extract the string
# from the key OPENSTACK_CONFIG_DB_KEY, in the section specified by
# OPENSTACK_CONFIG_DB_SECTION.

import os
import sys
import ConfigParser
import logging
from sqlalchemy import create_engine

# Create logger, console handler and formatter
logger = logging.getLogger('OpenStack-Helm DB Init')
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# Set the formatter and add the handler
ch.setFormatter(formatter)
logger.addHandler(ch)

db_connection = "mysql+pymysql://root:password@mariadb.kaas/mysql"

root_engine = create_engine(db_connection)
root_user = root_engine.url.username
root_password = root_engine.url.password
drivername = root_engine.url.drivername
database = "ironic"
user = "ironic"
password = "password"
host = root_engine.url.host
port = root_engine.url.port
connection = root_engine.connect()
connection.close()
logger.info("Tested connection to DB @ {0}:{1} as {2}".format(
    host, port, root_user))

root_engine.execute("CREATE DATABASE IF NOT EXISTS {0}".format(database))
logger.info("Created database {0}".format(database))

root_engine.execute(
    "GRANT ALL ON `{0}`.* TO \'{1}\'@\'%%\' IDENTIFIED BY \'{2}\'".format(
        database, user, password))
logger.info("Created user {0} for {1}".format(user, database))
res = os.system("ironic-dbsync --config-file /etc/ironic.conf create_schema")
sys.exit(res)
{{- end }}
