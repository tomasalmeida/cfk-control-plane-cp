#!/bin/bash

cd cp-demo
./scripts/stop.sh
cd ..
rm -rf cp-demo
cd cfk
kind delete cluster
cd ..