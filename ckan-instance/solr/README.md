# SOLR for CKAN instance

This Docker image is used to setup a SOLR server for ckan restore from backup

## Building and publishing

You should be logged-in to GitHub container registry with relevant permissions

```
docker build -t ghcr.io/whiletrue-industries/srm-devops-ckan-solr helm/ckan/solr &&\
docker push ghcr.io/whiletrue-industries/srm-devops-ckan-solr
```