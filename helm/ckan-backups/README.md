## Ckan Backups Chart

This chart should be deployed on an existing CKAN datacity namespace

### Create data backup secret

These are the credentials for the backup target

```
kubectl create secret generic srm-data-backup \
    --from-literal=AWS_ACCESS_KEY_ID= \
    --from-literal=AWS_SECRET_ACCESS_KEY \
    --from-literal=TARGET_BUCKET_PATH=
```

### Create DB backup secret

These are the credentials for the backup target

```
kubectl create secret generic srm-db-backup \
    --from-literal=AWS_ACCESS_KEY_ID= \
    --from-literal=AWS_SECRET_ACCESS_KEY \
    --from-literal=TARGET_BUCKET_PATH=
```
