# srm-devops

Devops related code for SRM

## Kubernetes Infrastructure as code

The Kubernetes infrastructure is managed as code which is continuously deployed.
Helm charts specify the infrastructure components which are then deployed to different environments 
with different configurations.

Helm charts are under `helm/` directory, they are standard helm charts which can be tested locally 
using Minikube or any other Kubernetes cluster.

Changes committed to `main` branch are synced using ArgoCD to the relevant cluster/namespace as defined [here](https://github.com/hasadna/hasadna-k8s/blob/master/apps/hasadna-argocd/values-hasadna.yaml)

Chart values are defined as helm value files inside the chart directory:

* `values.yaml` - default values which should be relevant to any environment
* `values.ENVIRONMENT.yaml` - values relevant only to the specified `ENVIRONMENT` (e.g. `values-production.yaml` / `values-staging.yaml`)
* `values.auto-updated.yaml` - auto-updated values which are relevant to any environment
* `values.auto-updated.ENVIRONMENT.yaml` - auto-updated values which are relevant only to the specified `ENVIRONMENT` (e.g. `values.auto-updated.production.yaml`)

### Clusters

The different clusters which are used are defined under [clusters/](/clusters/).

## Local development / testing environment

Docker Compose is used to provide a local environment for development / testing which includes all components.

Pull all the latest images for the apps:

```
docker-compose pull
```

(Alternatively, check the image name in docker-compose.yaml and tag an image that you built with that image name.)

### srm-api

```
docker-compose up -d srm-api kibana
```

Wait a few seconds for all services to start

* Make a request to Elasticsearch: `curl http://elastic:Aa123456@localhost:9200`
* Log-in to Kibana at http://localhost:5601 with username `elastic` password `Aa123456`
* Access PostgreSQL: `PGPASSWORD=postgres psql -h localhost -U postgres`
* Make a request to SRM API: `curl http://localhost:5000/api/idx/get/foo` (should get a 404 error)

### srm-etl

Create .env file

```
bin/generate_key_pair.sh > .env
```

Add environment variables for the ETL server (empty secrets will need to be updated with real values):

```
cat .etl.env >> .env
```

Generate Google OAuth credentials - https://console.developers.google.com/apis/credentials

```
echo GOOGLE_KEY=XXXX >> .env
echo GOOGLE_SECRET=YYYY >> .env
```

Start srm-etl

```
docker-compose up -d srm-etl
```

Wait a few seconds, then login at http://localhost:15000 (you will be denied)

Set the user as an admin user:

```
docker-compose exec srm-etl bash -c "python mk_admin.py"
```

* Login with that user at http://localhost:15000

### srm-frontend

```
docker-compose up -d srm-frontend
```

* Access the frontend at http://localhost:4000

### db backup

Set the following AWS S3 configuration in `.env` file:

```
DB_BACKUP_BUCKET=
DB_BACKUP_AWS_ACCESS_KEY_ID=
DB_BACKUP_AWS_SECRET_ACCESS_KEY=
```

Create a DB backup:

```
docker-compose run db-backup
```