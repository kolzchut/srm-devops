# Aws S3 Backup

This Docker image is used to setup cronjob on Kubernetes to backup local filesystem volumes to AWS S3

It tar-gzips the directory, saves with a filename of current date/time and uploads to AWS S3

## Building and publishing

You should be logged-in to GitHub container registry with relevant permissions

```
docker build -t ghcr.io/whiletrue-industries/srm-devops-aws-s3-backup aws-s3-backup &&\
docker push ghcr.io/whiletrue-industries/srm-devops-aws-s3-backup
```