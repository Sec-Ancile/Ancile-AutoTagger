import os
from dotenv import load_dotenv

load_dotenv()

db_name = os.getenv('POSTGRES_DB', 'cachedb')
db_user = os.getenv('POSTGRES_USER', 'root')
db_password = os.getenv('POSTGRES_PASSWORD', 'root123@')

sql_script = f"""
-- Check if the database already exists
DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_database WHERE datname = '{db_name}') THEN
      PERFORM dblink_exec('dbname=postgres', 'CREATE DATABASE {db_name}');
   END IF;
END
$$;

-- Switch to the newly created database
\\c {db_name};

-- Create a user with the specified username and password
DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '{db_user}') THEN
      CREATE USER {db_user} WITH ENCRYPTED PASSWORD '{db_password}';
      ALTER USER {db_user} WITH SUPERUSER;
   END IF;
END
$$;
"""

with open('init.sql', 'w') as f:
    f.write(sql_script)
