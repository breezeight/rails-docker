#!/usr/bin/env bash

set -e

# Only do this if /etc/hosts is writable (Docker < 1.2.0 compatibility)
if [ -w /etc/hosts ]; then
    cat /etc/hosts | grep '_' | sed 's/_/-/g' >> /etc/hosts
fi
