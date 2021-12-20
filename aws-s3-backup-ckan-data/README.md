# Aws S3 Backup of CKAN Data

This Docker image is used to setup cronjob on Kubernetes to backup CKAN data to AWS S3

It downloads all files from CKAN Data Google Cloud Storage to a zip file with filename of 
current date/time and uploads to AWS S3

## Building and publishing

You should be logged-in to GitHub container registry with relevant permissions

```
docker build -t ghcr.io/whiletrue-industries/srm-devops-aws-s3-backup-ckan-data aws-s3-backup-ckan-data &&\
docker push ghcr.io/whiletrue-industries/srm-devops-aws-s3-backup-ckan-data
```