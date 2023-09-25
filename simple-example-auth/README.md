
## Start up

### cp
```shell
cd cp
docker-compose up -d
watch -n1 docker-compose ps -a
```

### cfk

#### Using kind

Install kind from the website or via your package manager. Then run:

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

## Create secret with credentials for Kubernetes

Run in folder `cfk`:

```shell
kubectl apply -f admin-secret.yml
```

## Try to create topics without proper credentials

```shell
kubectl apply -f data/topics.yml
```

Watch logs of the operator, which should fail to create the resource (stop with Ctrl-C):

```shell
kubectl -n confluent logs -f -l app=confluent-operator
```

## Create topics

```shell
kubectl apply -f data/topics.yml
```

## List topics

```shell
kafka-topics --bootstrap-server kafka-1:29092 --command-config producer.properties --list
```

## Produce/Consume to topic

```bash
kafka-console-producer --broker-list kafka-1:29092 --producer.config producer.properties --topic demo-topic-1
kafka-console-consumer --bootstrap-server kafka-1:29092 --consumer.config consumer.properties --topic demo-topic-1 --from-beginning
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
kubectl exec --stdin --tty deploy/confluent-operator -- /bin/bash
```
