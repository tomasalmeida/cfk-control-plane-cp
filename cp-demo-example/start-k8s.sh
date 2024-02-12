#!/bin/bash

cd cfk
kind create cluster --config kind-basic-cluster.yaml
kubectl cluster-info --context kind-kind
cd ..