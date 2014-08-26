#!/usr/bin/env bash

set -e

WEBAPP_PATH=/home/app/webapp

# In case the log folder is a mounted volume, its
# permissions might be wrong. Fix them.
WEBAPP_LOG_PATH="$WEBAPP_PATH/log"

mkdir -p "$WEBAPP_LOG_PATH"
chown app:app "$WEBAPP_LOG_PATH"
