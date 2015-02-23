#!/usr/bin/env bash

set -e

WEBAPP_PATH=/home/app/webapp

# In case the log folder is a mounted volume, its
# permissions might be wrong. Fix them.
WEBAPP_LOG_PATH="$WEBAPP_PATH/log"

mkdir -p "$WEBAPP_LOG_PATH"
chown app:app "$WEBAPP_LOG_PATH"

# download fluentd config if configured
if [ -n "$FLUENTD_CONFIG_URL" ]; then
  echo "Override fluentd configuration with $FLUENTD_CONFIG_URL"
  curl "$FLUENTD_CONFIG_URL" > /etc/td-agent/td-agent.conf.remote

  if [ $? -eq 0 ]; then
    cp -f /etc/td-agent/td-agent.conf.remote /etc/td-agent/td-agent.conf
  else
    echo "override failed"
  fi
# otherwise use default and only substitute URL, user and password and other options
else
  if [ -z "$ES_HOST" ]; then
    rm /etc/td-agent/td-agent.conf
    echo logging is not configured >&2
    exit 0
  fi

  sed -i'' -e 's|<es_host>|'$ES_HOST'|' /etc/td-agent/td-agent.conf
  sed -i'' -e 's|<es_index>|'"${ES_INDEX:-fluentd}"'|' /etc/td-agent/td-agent.conf
  sed -i'' -e 's|<es_type>|'"${ES_TYPE:-fluentd}"'|' /etc/td-agent/td-agent.conf
  sed -i'' -e 's|<es_tag>|'"${ES_TAG:-rails}"'|' /etc/td-agent/td-agent.conf

  if [ -n "$ES_USER" ]; then
    sed -i'' -e 's|<es_user>|'$ES_USER'|' /etc/td-agent/td-agent.conf
  else
    sed -i'' -E '/<es_user>/d' /etc/td-agent/td-agent.conf
  fi

  if [ -n "$ES_PASSWORD" ]; then
    sed -i'' -e 's|<es_password>|'$ES_PASSWORD'|' /etc/td-agent/td-agent.conf
  else
    sed -i'' -E '/<es_password>/d' /etc/td-agent/td-agent.conf
  fi

  if [ -n "$ES_PATH" ]; then
    sed -i'' -e 's|<es_path>|'$ES_PATH'|' /etc/td-agent/td-agent.conf
  else
    sed -i'' -E '/<es_path>/d' /etc/td-agent/td-agent.conf
  fi

  if [ -n "$ES_PORT" ]; then
    sed -i'' -e 's|<es_port>|'$ES_PORT'|' /etc/td-agent/td-agent.conf
  else
    sed -i'' -E '/<es_port>/d' /etc/td-agent/td-agent.conf
  fi

  if [ -n "$ES_SCHEME" ]; then
    sed -i'' -e 's|<es_scheme>|'$ES_SCHEME'|' /etc/td-agent/td-agent.conf
  else
    sed -i'' -E '/<es_scheme>/d' /etc/td-agent/td-agent.conf
  fi

  echo "logging to $ES_HOST"
fi
