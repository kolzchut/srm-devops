## Ckan Instance

This chart is used to restore the CKAN instance from backup

### Prepare infrastructure and restore from backup

#### Kubernetes

You should have a Kubernetes cluster to host the ckan instance. For this guide we will
use Google Cloud SQL, so you should also have the cluster hosted in Google Kubernetes engine
as well, on the same region, network and subnet as the SQL instance so it will be able 
to access it without exposing the DB publicly.

Using Google Kubernetes Engine you can use the following recommended configuration:

* Location type: Zonal, europe-west1-d
* Master Version: 1.19
* Number of nodes: 3
* Auto Upgrade: off
* Machine type: Container-optimized OS, e2-medium

#### Database

Recommended Google Cloud SQL instance:

* type: PostgreSQL
* Zone: europe-west1-d
* Database Version: PostgreSQL 9.6
* Connect using public & private IPs
* Machine type: 1vCPU, 3.75GM RAM
* Storage type: SSD 10GB, enable automatic increase
* Add flag `max_connections` = `1000`

Install [cloud_sql_proxy](https://cloud.google.com/sql/docs/mysql/sql-proxy#install) and run the following to proxy the instance to localhost:5432

```
cloud_sql_proxy -instances=PROJECT:REGION:INSTANCE_NAME=tcp:5432
```

In a new terminal, run the following to start a Bash shell with required tools to restore from backup.
Replace the env var values with relevant AWS credentials and the Google Cloud SQL main password:

```
docker run -it --entrypoint=bash --network=host \
    -e AWS_ACCESS_KEY_ID= -e AWS_SECRET_ACCESS_KEY= \
    -e PGPASSWORD= \
    ghcr.io/whiletrue-industries/srm-devops-aws-s3-backup-ckan-db@sha256:891ceb90412953f6cc9f16398d6f2785db3a59c0789cba6c495d93c4ee032715
```

Find the latest main backup, for example - the following command will list all backups from December, 2021:

```
aws s3 ls s3://kolzchut-backups/ckan-db/main-2021-12
```

Download the relevant backup and unzip

```
aws s3 cp s3://kolzchut-backups/ckan-db/main-2021-12-22T10-25-51.sql.gz ./main.sql.gz &&\
gunzip main.sql.gz
```

Find out the main role name:

```
cat main.sql | grep "ALTER TABLE" | grep "OWNER TO" | head -n1
```

Set the role name and password (generate a password) in env vars:

```
MAIN_ROLE_NAME=srm-e664cac9300c
MAIN_ROLE_PASSWORD='****************'
```

Create the main role and database:

```
echo "CREATE ROLE" '"'"${MAIN_ROLE_NAME}"'"' "WITH LOGIN PASSWORD" "'""${MAIN_ROLE_PASSWORD}""'" "NOSUPERUSER NOCREATEDB NOCREATEROLE;" \
    | psql -h localhost -U postgres &&\
echo "GRANT \"${MAIN_ROLE_NAME}\" TO postgres;" \
    | psql -h localhost -U postgres &&\
echo "CREATE DATABASE \"${MAIN_ROLE_NAME}\";" \
    | psql -h localhost -U postgres &&\
echo "
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
ALTER TABLE spatial_ref_sys OWNER TO \"${MAIN_ROLE_NAME}\"
" | psql -h localhost -U postgres
```

Restore the main DB:

```
cat main.sql \
    | PGPASSWORD="${MAIN_ROLE_PASSWORD}" psql -h localhost -U "${MAIN_ROLE_NAME}" -v ON_ERROR_STOP=1 \
        "${MAIN_ROLE_NAME}"
```

Find the latest datastore backup, for example - the following command will list all backups from December, 2021:

```
aws s3 ls s3://kolzchut-backups/ckan-db/datastore-2021-12
```

Download the relevant backup and unzip

```
aws s3 cp s3://kolzchut-backups/ckan-db/datastore-2021-12-22T10-25-51.sql.gz ./datastore.sql.gz &&\
gunzip datastore.sql.gz
```

Find out the datastore role name:

```
cat datastore.sql | grep "ALTER TABLE" | grep "OWNER TO" | head -n1
```

Set datastore role names and passwords in env vars:

```
DATASTORE_ROLE_NAME="srm-e664cac9300c-datastore"
DATASTORE_ROLE_PASSWORD='********'
DATASTORE_READONLY_ROLE_NAME="${DATASTORE_ROLE_NAME}-readonly"
DATASTORE_READONLY_ROLE_PASSWORD='********'
```

Create the datastore role and database:

```
echo "CREATE ROLE" '"'"${DATASTORE_ROLE_NAME}"'"' "WITH LOGIN PASSWORD" "'""${DATASTORE_ROLE_PASSWORD}""'" "NOSUPERUSER NOCREATEDB NOCREATEROLE;" \
    | psql -h localhost -U postgres &&\
echo "GRANT \"${DATASTORE_ROLE_NAME}\" TO postgres;" \
    | psql -h localhost -U postgres &&\
echo "CREATE DATABASE \"${DATASTORE_ROLE_NAME}\";" \
    | psql -h localhost -U postgres &&\
echo "CREATE ROLE" '"'"${DATASTORE_READONLY_ROLE_NAME}"'"' "WITH LOGIN PASSWORD" "'""${DATASTORE_READONLY_ROLE_PASSWORD}""'" "NOSUPERUSER NOCREATEDB NOCREATEROLE;" \
    | psql -h localhost -U postgres &&\
```

Restore the datastore DB:

```
cat datastore.sql \
    | PGPASSWORD="${DATASTORE_ROLE_PASSWORD}" psql -h localhost -U "${DATASTORE_ROLE_NAME}" -v ON_ERROR_STOP=1 \
        "${DATASTORE_ROLE_NAME}"
```

#### Storage

Create a Google Cloud Storage bucket:

* Location: region, europe-west1
* Storage Class: standard
* Permissions: fine-grained

Create a service account and HMAC key

* Cloud storage > Settings > Interoperability > Create a key for another service account
* Create new account without any roles
* Keep the access key / secret for this account 

Give the service account permissions for the bucket

* Cloud Storage > Bucket > Permissions
* Add the service account with Storage Object Admin role

Set CORS on the bucket

```
gsutil cors set ckan-instance/cors-config.json gs://BUCKET_NAME
```

Download the latest ckan-data backup zip file

Run the following to extract the data:

```
TEMPDIR=`mktemp -d` &&\
cp 2021-12-20T20-54-42.zip $TEMPDIR/ &&\
cd $TEMPDIR &&\
unzip 2021-12-20T20-54-42.zip &&\
rm 2021-12-20T20-54-42.zip
```

Restore the data:

```
gsutil -m cp -Jr ./ gs://BUCKET_NAME/
```

Delete the temporary directory

```
rm -rf $TEMPDIR
```

### Create ckan configuration

Copy `ckan-instance/ckan-secret.example` directory to `ckan-instance/ckan-secret`

Download the latest ckan-instance backup `production.ini` file and save at `ckan-instance/ckan-secret/production.ini`

Edit the file and change the following settings:

* `sqlalchemy.url`: main database credentials (`postgresql://MAIN_ROLE_NAME:MAIN_ROLE_PASSWORD@DB_INTERNAL_IP/MAIN_ROLE_NAME`)
* `ckan.datastore.write_url`: datastore credentials (`postgresql://DATASTORE_ROLE_NAME:DATASTORE_ROLE_PASSWORD@DB_INTERNAL_IP/DATASTORE_ROLE_NAME`)
* `ckan.datastore.read_url`: datastore readonly credentials (`postgresql://DATASTORE_READONLY_ROLE_NAME:DATASTORE_READONLY_ROLE_PASSWORD@DB_INTERNAL_IP/DATASTORE_ROLE_NAME`)
* `ckan.site_url`: change depending on where the site will be available
* `solr_url`: change to `http://solr:8983/solr/ckan`
* `smtp.*`: change to your smtp provider details
* `ckanext.s3filestore.*`: change to the credentials of the Google Cloud Storage account you created

### Deploy

Make sure you are connected to the relevant cluster

Create a namespace:

```
kubectl create ns srm-ckan
```

Run a dry-run and review the templates:

```
helm -n srm-ckan upgrade --install srm-ckan ckan-instance --dry-run
```

If everything looks OK, deploy:

```
helm -n srm-ckan upgrade --install srm-ckan ckan-instance --dry-run
```

Run the following to reindex the data to SOLR:

```
kubectl -n srm-ckan exec deployment/ckan -- ckan-paster --plugin=ckan search-index -c /etc/ckan/production.ini rebuild
```

Start a port-forward to the nginx service:

```
kubectl -n srm-ckan port-forward service/nginx 8080
```

You should see the site at http://localhost:8080
