
# Example for managing CP with authentication using CFK

## Quick setup for Confluent Platform
```shell
cd cp
./up
```

## cfk

### Using kind

Install kind from the website or via your package manager. Then run:

```shell
kind create cluster --config cfk/kind-basic-cluster.yaml
kubectl cluster-info --context kind-kind
kubectl create namespace confluent
kubectl config set-context --current --namespace confluent
helm repo add confluentinc https://packages.confluent.io/helm --insecure-skip-tls-verify
helm repo update
helm upgrade --install confluent-operator confluentinc/confluent-for-kubernetes
kubectl get pods -A -o wide
cd ..
```

### Create admin rest class and secret with credentials for accessing brokers and schema registry

Run in folder `cfk`:

```shell
kubectl apply -f cfk/admin-rest-class
kubectl apply -f cfk/admin-secret.yml
```

### Create topics

```shell
kubectl apply -f customer-resources/topics.yml
```

### List topics

```shell
kafka-topics --bootstrap-server kafka-1:29092 --command-config producer.properties --list
```

### Produce/Consume to topic

```bash
kafka-console-producer --broker-list kafka-1:29092 --producer.config producer.properties --topic demo-topic-1
kafka-console-consumer --bootstrap-server kafka-1:29092 --consumer.config consumer.properties --topic demo-topic-1 --from-beginning
```

### Schema Registry

First, create a configmap containing the schema, then the schema custom resource:

```shell
kubectl apply -f customer-resources/payment-schema-configmap.yml
kubectl apply -f customer-resources/payment-schema.yml
```

Please have a look below to find out how to check that all resources have been created in CP.

## Confluent Platform

This describes how CP has been set up automatically and shows how to test certain features.
### Using ACLs for schema registry

ACLs should have been set up already (if used the `up` script). You can check them.

List ACLs:

```shell
sr-acl-cli --config ./schema-registry-admin.properties --list
```

Use the following only if you haven't used the "up" script:
Grant "admin" access to everything, "producer" and "consumer" only read access (but to all subjects!):

```shell
sr-acl-cli --config ./schema-registry-admin.properties --add -s '*' -p admin -o '*'
sr-acl-cli --config ./schema-registry-admin.properties --add -s '*' -o SUBJECT_READ -p producer
sr-acl-cli --config ./schema-registry-admin.properties --add -o GLOBAL_COMPATIBILITY_READ -p producer
sr-acl-cli --config ./schema-registry-admin.properties --add -s '*' -o SUBJECT_READ -p consumer
sr-acl-cli --config ./schema-registry-admin.properties --add -o GLOBAL_COMPATIBILITY_READ -p consumer
```

``
#### List schemas with curl

First, get a bearer token to perform basic auth:

```shell
export BEARER_ADMIN=$(echo -n "admin:admin-secret" | base64)
export BEARER_PRODUCER=$(echo -n "producer:producer-secret" | base64)
export BEARER_CONSUMER=$(echo -n "consumer:consumer-secret" | base64)
```

Then, run curl to get the list of schemas:

```shell
curl -H "AUTHORIZATION: Basic $BEARER_ADMIN" schema-registry:8081/subjects
```

You should see "payments-value" in the list, which has been created by CFK.

Try registering another schema:

```shell
curl -X POST -H "AUTHORIZATION: Basic $BEARER_ADMIN" -H "Content-Type: application/vnd.schemaregistry.v1+json"  schema-registry:8081/subjects/Kafka-value/versions/  -d '{ "schema":"{\"type\":\"record\",\"name\":\"PositionValue\",\"namespace\":\"clients.avro\",\"fields\":[{\"name\":\"latitude\",\"type\":\"double\"},{\"name\":\"longitude\",\"type\":\"double\"}]}"}'
```

Show versions of schema:

```shell
curl -H "AUTHORIZATION: Basic $BEARER_ADMIN" schema-registry:8081/subjects/Kafka-value/versions
```

Show the schema (use one of the versions shown by the last command, in the example we use "4"):

```shell
curl -H "AUTHORIZATION: Basic $BEARER_ADMIN" schema-registry:8081/subjects/Kafka-value/versions/1
```

Try registering a schema as "producer" (should not work):

```shell
curl -X POST -H "AUTHORIZATION: Basic $BEARER_PRODUCER" -H "Content-Type: application/vnd.schemaregistry.v1+json"  schema-registry:8081/subjects/Kafka-value/versions/  -d '{ "schema":"{\"type\":\"record\",\"name\":\"PositionValue\",\"namespace\":\"clients.avro\",\"fields\":[{\"name\":\"latitude\",\"type\":\"double\"},{\"name\":\"longitude\",\"type\":\"double\"}]}"}'
```

List schema as "producer" (should work):

```shell
curl -H "AUTHORIZATION: Basic $BEARER_PRODUCER" schema-registry:8081/subjects/Kafka-value/versions/1
```

Try to delete the schema as "producer" (should not work):

```shell
curl -H "AUTHORIZATION: Basic $BEARER_PRODUCER" -X DELETE http://localhost:8081/subjects/Kafka-value
```



Delete the schema as "admin":

```shell
curl -H "AUTHORIZATION: Basic $BEARER_ADMIN" -X DELETE http://localhost:8081/subjects/Kafka-value
```

## clean up

```shell
cd cfk
kind delete cluster
cd ../cp
docker-compose down -v
```

## Useful Commands
Check the logs of the confluent operator (exit with Ctrl-C):

```shell
kubectl -n confluent logs -f -l app=confluent-operator
```

Jump into the operator container:

```shell
kubectl exec --stdin --tty deploy/confluent-operator -- /bin/bash
```
