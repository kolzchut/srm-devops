# Aws S3 Backup of CKAN DB

This Docker image is used to setup cronjob on Kubernetes to backup CKAN DB to AWS S3

It is meant to run on the Datacity cluster so it can connect to the CKAN DB 
and upload DB dump with filename of current date/time to AWS S3

## Building and publishing

You should be logged-in to GitHub container registry with relevant permissions

```
docker build -t ghcr.io/whiletrue-industries/srm-devops-aws-s3-backup-ckan-db aws-s3-backup-ckan-db &&\
docker push ghcr.io/whiletrue-industries/srm-devops-aws-s3-backup-ckan-db
```