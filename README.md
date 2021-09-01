# srm-devops

Devops related code for SRM

## Kubernetes Infrastructure as code

The Kubernetes infrastructure is managed as code which is continuously deployed.
Helm charts specify the infrastructure components which are then deployed to different environments with different configurations.

### Helm Charts

Helm charts are under `helm/` directory, they are standard helm charts which can be tested locally using Minikube or any other Kubernetes cluster.

Changes committed to `main` branch are published to our Helm charts repository at [helm-charts branch](https://github.com/whiletrue-industries/srm-devops/tree/helm-charts).
Charts are versioned using the version defined in the helm Chart.yaml and suffixed with the commit SHA.
Latest chart version is saved in the chart directory at `helm/CHART_NAME/latest-chart-version.txt`.

You can publish a chart to our repository for testing by running `bin/helm_publish_chart.sh CHART_NAME PUBLISH_VERSION`.
This will lint, package, commit and push the chart to the helm-charts branch.
PUBLISH_VERSION must be a valid SemVer with a suffix e.g. `v0.0.0-testing123`

### Environments

Environments are under `environments/` directory. Each environment correspond to a specific cluster and namespace in that cluster.

Each environment has a file at `environments/ENVIRONMENT_NAME/env.sh` which defines the environment cluster and namespace in env vars.
Optionally, another file can be added which is not committed to git at `environments/ENVIRONMENT_NAME/.env` - for any secret values for that environment.

Charts deployed to an environment are defined at `environments/ENVIRONMENT_NAME/charts/`.
Each subdirectory corresponds to a helm chart which is deployed to that environment.
Each helm chart under that directory must have a values.yaml file at `environments/ENVIRONMENT_NAME/charts/CHART_NAME/values.yaml`.
This file can include values which overrides the default chart values. The file must exists even if no overrides are needed (it can remain empty).

The deployed chart version is defined in the following files:

* `environments/ENVIRONMENT_NAME/charts/CHART_NAME/chart_version.txt` - defined manually to a specific chart version (from the helm-charts repository)
* `helm/CHART_NAME/latest-chart-version.txt` - fallback in case the chart_version.txt file does not exist, this is always the latest chart version in the helm-charts repository

Additional files which affect the deployment of the chart:

* `helm/CHART_NAME/values.auto-updated.yaml` - these values are included regardless of deployed chart version, these values are overriden by the `values.auto-updated.yaml` and `values.yaml` files.
* `environments/ENVIRONMENT_NAME/charts/CHART_NAME/values.auto-updated.yaml` - automatically updated values, overriden by the `values.yaml` file
* `environments/ENVIRONMENT_NAME/charts/CHART_NAME/chart_name.txt` - allows to deploy the same chart multiple times on the same environment
* `environments/ENVIRONMENT_NAME/charts/CHART_NAME/release_name.txt` - required only if chart_name.txt is provided - allows to specify the helm release name (otherwise uses the chart name)
* `environments/ENVIRONMENT_NAME/environment_label.txt` - optional label for the entire environment, such as `production`, affects the following:
    * includes an additional chart auto updated values from `helm/CHART_NAME/values.auto-updated.ENVIRONMENT_LABEL.yaml` - overrides the chart auto-updated values

### Continuous Deployment

Every push to main branch runs the continous deployment script.
This script handles the following actions:

* If helm chart was changed - publish it to the helm charts repo
* If environment chart was changed - deploy it to the relevant environment

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
