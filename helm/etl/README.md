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
