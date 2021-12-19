## ETL Helm Chart

Contains the ETL, API and all related infrastructure

### Secrets

#### elasticsearch

Set elasticsearch password:

```
ELASTIC_PASSWORD=XXXXXXXX
```

Create the secret:

```
kubectl create secret generic elasticsearch \
    --from-literal=ELASTIC_PASSWORD=$ELASTIC_PASSWORD \
    --from-literal=ES_HTTP_AUTH=elastic:$ELASTIC_PASSWORD
```

Set the secret name in values `elasticsearch.secretName`

#### ETL

Create ETL secret:

```
kubectl create secret generic etl \
    --from-literal=SENDGRID_API_KEY= \
    --from-literal=GOOGLE_KEY= \
    --from-literal=GOOGLE_SECRET= \
    --from-literal=PUBLIC_KEY_B64= \
    --from-literal=PRIVATE_KEY_B64=
```

(Optional) create S3 secret:

```
kubectl create secret generic etl-s3 \
    --from-literal=BUCKET_NAME= \
    --from-literal=AWS_ACCESS_KEY_ID= \
    --from-literal=AWS_SECRET_ACCESS_KEY= \
    --from-literal=S3_ENDPOINT_URL= \
    --from-literal=AWS_REGION=
```

Set the secret name in values `etl.secretName`

#### DB Backup

```
kubectl create secret generic db-backup \
    --from-literal=DB_BACKUP_BUCKET= \
    --from-literal=DB_BACKUP_AWS_ACCESS_KEY_ID= \
    --from-literal=DB_BACKUP_AWS_SECRET_ACCESS_KEY=
```

#### Elasticsearch Backup

```
kubectl create secret generic elasticsearch-backup \
    --from-literal=S3_CLIENT_DEFAULT_ACCESS_KEY= \
    --from-literal=S3_CLIENT_DEFAULT_SECRET_KEY=
```

### Post-deploy tasks

#### Setup Elasticsearch scheduled backups

* Log-in to Kibana > Stack Management > Snapshot and Restore
* Register a repository:
  * name: `kolzchut-backups`
  * type: AWS S3
  * bucket: name of the bucket
  * base path: `srm-etl-elasticsearch`
* Click on verify repository to verify the connection to S3
* Create a policy:
  * name: `weekly-snapshots`
  * snapshot name: `weekly-snapshot`
  * repository: `kolzchut-backups`
  * schedule: every week, on sunday
* click on "run now" to test it and make sure the snapshot is created