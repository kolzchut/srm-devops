# Manual Kubernetes Operations

**warning! It is not recommended to perform manual operations defined in this document**

**You should instead follow the instructions for making changes to the code in the README**

## Connecting to the environments

### Install

* Install `kubectl` and `helm`
* Get the `srm-devops.kubeconfig` file
* add `.env` file at `clusters/*/.env` with the following contents:
```
export KUBECONFIG=/path/to/srm-devops.kubeconfig
```

### Connect

Connect to a cluster (CLUTER_NAME corresponds to a subdirectory under `clusters/`):

```
source bin/connect_cluster.sh CLUSTER_NAME
```

Connect to an environment (ENVIRONMENT_NAME corresponds to a subdirectory under `environments/`):

```
source bin/connect_environment.sh ENVIRONMENT_NAME
```

### Deploy a chart to an environment

```
bin/deploy_environment_chart.sh environments/ENVIRONMENT_NAME/charts/CHART_NAME HELM_ARGS...
```

See the README for details of the deployment logic.

You can optionally deploy from the local helm chart instead of from the chart repo by setting env var `FROM_PATH=yes`
