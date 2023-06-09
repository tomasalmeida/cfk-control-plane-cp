
# Goal

CfK allows us to control resources outside kubernetes. It would be useful to use the capabilities of CfK to create and delete topics and RBAC in a CP outside CfK.

## Start up

### cp
```shell
cd cp
docker-compose up -d
watch -n1 docker-compose ps -a
```

### cfk

```shell
cd cfk
kind create cluster --config kind-basic-cluster.yaml
kubectl cluster-info --context kind-kind
kubectl create namespace confluent
kubectl config set-context --current --namespace confluent
helm repo add confluentinc https://packages.confluent.io/helm --insecure-skip-tls-verify
helm repo update
helm upgrade --install confluent-operator confluentinc/confluent-for-kubernetes
kubectl get pods -A -o wide
cd ..
```

## Create topics

```shell
kubectl apply -f data/topics.yml
```

## clean up

```shell
cd cfk
kind delete cluster
cd ../cp
docker-compose down -v
```

## Commands
```shell
# get a shell in operator pod
kubectl exec --stdin --tty confluent-operator-7cc4fdc656-kzdnh -- /bin/bash
```

## References

* CFK API reference: https://docs.confluent.io/operator/current/co-api.html