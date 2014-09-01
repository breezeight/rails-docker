#!/usr/bin/env bash

set -e

su app -c 'RAILS_ENV=production bundle exec rake db:create || true'
su app -c 'RAILS_ENV=production bundle exec rake db:migrate'
su app -c 'RAILS_ENV=production bundle exec rake db:seed'
