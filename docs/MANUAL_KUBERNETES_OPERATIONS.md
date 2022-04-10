# Manual Kubernetes Operations

**warning! It is not recommended to perform manual operations defined in this document**

**You should instead follow the instructions for making changes to the code in the README**

## Connecting to the clusters

### Install

* Install `kubectl`
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

### Deploy a chart to an environment

Deployment to production environments must be done via ArgoCD on Hasadna's cluster. 
See https://github.com/hasadna/hasadna-k8s/blob/master/docs/argocd.md for details.

For local development or testing clusters you can use Helm to deploy the helm charts directly.
