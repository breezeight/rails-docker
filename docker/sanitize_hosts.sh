#!/usr/bin/env bash

set -e

cat /etc/hosts | grep '_' | sed 's/_/-/g' >> /etc/hosts
