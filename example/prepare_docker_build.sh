#!/usr/bin/env bash

# Requires Bundler >= 1.8 (not released as of 2014-09-01) for --no-install

set -e

# Only run `bundle package [...]` if Gemfile or Gemfile.lock have changed.
# `bundle package` unfortunately changes git repository folders on each run
# so running this always invalidates the Docker cache each time and makes it
# useless.
GEMFILES='Gemfile Gemfile.lock'
GEMFILE_STATE_FILE="vendor/cache-Gemfile-state"
GEMFILE_STATE=$(cat $GEMFILES | openssl sha1)

if [ "$GEMFILE_STATE" == "$(cat $GEMFILE_STATE_FILE)" ]; then
    echo "'$GEMFILES' unchanged, skipping "'`bundle package`.'
else
    echo "'$GEMFILES' changed, running "'`bundle package`...'
    bundle package --all --no-install
    echo "$GEMFILE_STATE" > "$GEMFILE_STATE_FILE"
fi
