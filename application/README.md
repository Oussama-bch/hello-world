## Getting started

Those instructions will make the project up and running on your local machine for development and testing purposes. 
See [terraform](https://github.com/Oussama-bch/hello-world/blob/main/terraform/README.md) section for notes on how to deploy the project on a live system.

### Prerequisites

Before statring, you must install all dependencies below inside a ***centos-7*** Linux environment
#### 1- Install Python 3.6.8
```
yum install gcc openssl-devel bzip2-devel libffi-devel

cd /usr/src
wget https://www.python.org/ftp/python/3.6.8/Python-3.6.8.tgz

tar xzf Python-3.6.8.tgz

cd Python-3.6.8
./configure --enable-optimizations
make altinstall

rm /usr/src/Python-3.6.8.tgz

python3 -V
```
##### 2- Install virtualenv
```
python3 -m pip install --user --upgrade pip
python3 -m pip install --user virtualenv
```
##### 3- Install the latest version of Docker

```
sudo yum install docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
```
##### 4- Install the Postgres Database

```
sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo yum install -y postgresql14-server
sudo /usr/pgsql-14/bin/postgresql-14-setup initdb
sudo systemctl enable postgresql-14
sudo systemctl start postgresql-14
```

##### 5- Create Database, user and table
This instruction can be done using [psql cli](https://docs.postgresql.fr/10/app-psql.html) or [pgAdmin](https://www.pgadmin.org/)
```
-- create database and user
CREATE DATABASE [DATABASE_NAME];
CREATE USER [USERNAME] WITH PASSWORD '[PASSWORD]';
GRANT CONNECT ON DATABASE [DATABASE_NAME] TO [USERNAME];
GRANT USAGE ON SCHEMA public TO [USERNAME];
GRANT all privileges on all tables in schema public TO [USERNAME];

-- create table
DROP TABLE IF EXISTS users;

CREATE TABLE users (
	user_id serial PRIMARY KEY,
	username VARCHAR UNIQUE,
	date_of_birth DATE NOT NULL
);
```
##### 5- Fill database config file
You must fill [database.ini](https://github.com/Oussama-bch/hello-world/blob/main/application/database.ini) with resources created above.
```
[postgresql]
host=[DATABASE HOST URL]
database=[DATABASE NAME]
user=[USERNAME]
password=[PASSWORD]
```
## Unit tests
Unit tests must be exectued inside a virtualenv.
##### 1- Activate virtualenv
```
python3 -m venv my_venv
source env/bin/activate
```

##### 2- Install all requirements
```
pip3 install -r requirements.txt
```
##### 3- Run unit tests
```
python3 -m unittest unit_tests.py -v
```

## Service tests
Service tests must be executed inside a docker container
##### 1- Build docker image
```
docker build -t hello-worl:v0.1 .
```

##### 2- Run docker container
```
docker run -d -p 80:80 -t hello-world:v0.1
```
##### 3- Tests endpoints
```
# Test PUT request:
curl -X PUT -H "Content-Type: application/json" \
    -d '{"dateOfBirth":"2012-12-31"}' \ 
    http://localhost:80/hello/jhon

# Test GET request :
curl -X 'GET' \
  'http://localhost:80/hello/jhon' \
  -H 'accept: application/json'
```

## Authors

* **Oussama BEN CHARRADA** - *Initial work*