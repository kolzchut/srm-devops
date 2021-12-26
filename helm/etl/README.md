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

#### Minio Backup

```
kubectl create secret generic minio-backup \
    --from-literal=AWS_ACCESS_KEY_ID= \
    --from-literal=AWS_SECRET_ACCESS_KEY=
```

### Restoring from backup

To deploy the chart with DB data restored from backup, set the following helm values when deploying the chart for the first time:

* `db.restore.enabled`: set to true
* `db.restore.awsAccessKeyId`: AWS access key with permission for the relevant S3 bucket/path
* `db.restore.awsSecretAccessKey`: AWS secret access key with permissions for the relevant S3 bucket/path
* `db.restore.backupBucketPath`: S3 bucket/path pointing to the srm-etl-db backup filename to restore from

### Post-deploy tasks

#### Setup Elasticsearch to restore or create scheduled backups

If you want to restore from backup or create scheduled backups you need to do the following:

* Log-in to Kibana > Stack Management > Snapshot and Restore
* Register a repository:
  * name: `kolzchut-backups`
  * type: AWS S3
  * bucket: name of the bucket
  * base path: `srm-etl-elasticsearch`
* Click on verify repository to verify the connection to S3

To restore - you should see available snapshots and can select snapshots to restore

To create scheduled backups:

* Create a policy:
  * name: `weekly-snapshots`
  * snapshot name: `weekly-snapshot`
  * repository: `kolzchut-backups`
  * schedule: every week, on sunday
* click on "run now" to test it and make sure the snapshot is created

#### Restore Minio data

* Download the relevant minio backup data locally
* Copy the data over to the minio pod under directory `/data` (you can use `kubectl cp`)
* Restart the Minio pod
