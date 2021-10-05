import psycopg2
import boto3
import json
import os
from datetime import date, datetime
from botocore.exceptions import ClientError
from configparser import ConfigParser

# Get Database credentials from AWS SecretManager
def get_db_creds_from_secret_manager():
    secret_name = os.environ["SECRETMANAGER"]
    region_name = os.environ["AWS_REGION"]

    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name,
    )
    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name)
    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceNotFoundException':
            print("The requested secret " + secret_name + " was not found")
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            print("The request was invalid due to:", e)
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            print("The request had invalid params:", e)
        elif e.response['Error']['Code'] == 'DecryptionFailure':
            print(
                "The requested secret can't be decrypted using the provided KMS key:", e)
        elif e.response['Error']['Code'] == 'InternalServiceError':
            print("An error occurred on service side:", e)

    secret_data_dict = json.loads(get_secret_value_response['SecretString'])
    return secret_data_dict

# Get Database credentials from Local config file : database.ini (Used only in dev Mode)
def get_db_creds_from_local_file(filename='database.ini', section='postgresql'):
    # create a parser
    parser = ConfigParser()
    # read config file
    parser.read(filename)
    # get section, default to postgresql
    db = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            db[param[0]] = param[1]
    else:
        raise Exception(
            'Section {0} not found in the {1} file'.format(section, filename))
    return db

# Execute Select query on Database
def exec_select_query(query):
    conn = None
    try:
        try:
            os.environ["FARGATE"]
            params = get_db_creds_from_secret_manager()
        except:
            params = get_db_creds_from_local_file()
        finally:
            conn = psycopg2.connect(**params)
            cur = conn.cursor()
            cur.execute(query)
            records = cur.fetchone()
            cur.close()
            return (records)
    except (Exception, psycopg2.DatabaseError) as error:
        raise Exception("Database error : {}".format(error))
    finally:
        if conn is not None:
            conn.close()


# Execute Insert / Update query on Database
def exec_upsert_query(query):
    conn = None
    try:
        try:
            os.environ["FARGATE"]
            params = get_db_creds_from_secret_manager()
        except:
            params = get_db_creds_from_local_file()
        finally:
            conn = psycopg2.connect(**params)
            cur = conn.cursor()
            cur.execute(query)
            conn.commit()
            cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        raise Exception("Database error : {}".format(error))
    finally:
        if conn is not None:
            conn.close()

# Format response body message
def format_response(date_of_birth, username):
    now = datetime.now()
    if now.month == date_of_birth.month and now.day == date_of_birth.day:
        result = "Hello, {}! Happy birthday!".format(username)
    else:
        d1 = datetime(now.year, date_of_birth.month, date_of_birth.day)
        d2 = datetime(now.year+1, date_of_birth.month, date_of_birth.day)
        n_days = ((d1 if d1 > now else d2) - now).days + 1
        result = "Hello, {}! Your birthday is in {} day(s)".format(
            username, str(n_days))
    return (result)

# Generate SQL SELECT query
def gen_select_query(username):
    query = "SELECT date_of_birth FROM PUBLIC.users WHERE username = '{}'".format(
        username)
    return (query)

# Generate SQL UPSERT query
def gen_upsert_query(username, date_of_birth):
    query = "INSERT INTO PUBLIC.users (username, date_of_birth) VALUES('{}','{}') ON CONFLICT (username) DO UPDATE SET date_of_birth = EXCLUDED.date_of_birth".format(
        username, date_of_birth)
    return (query)

# Validate HTTP Body Request content
def validate_body_content(date_of_birth, username):

    err_msg1 = "dateOfBirth must be a valid date format : YYYY-MM-DD"
    err_msg2 = "YYYY-MM-DD must be a date before the today date"
    err_msg3 = "username must contain only letters"

    try:
        datetime.strptime(date_of_birth, '%Y-%m-%d')
    except ValueError as error:
        return ({"valid_request": False,
                 "error_message": err_msg1})

    if datetime.strptime(date_of_birth, '%Y-%m-%d') > datetime.now():
        return ({"valid_request": False,
                 "error_message": err_msg2})

    if not username.isalpha():
        return ({"valid_request": False,
                 "error_message": err_msg3})
    return ({"valid_request": True})
