#!/usr/bin/env bash

kubectl patch installation.operator.tigera.io default --type merge -p '{"spec":{"calicoNetwork":{"mtu":8450}}}'
