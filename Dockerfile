FROM phusion/passenger-ruby21:0.9.11
MAINTAINER Finn GmbH <info@finn.de>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y -o DPkg::Options::="--force-confold" install \
        libpq-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Enable and configure nginx
RUN rm -f /etc/service/nginx/down
COPY /docker/disable-version.conf /etc/nginx/conf.d/disable-version.conf
COPY /docker/webapp.conf /etc/nginx/sites-enabled/webapp.conf

# Disable default nginx host so app can be accessed without specific host
RUN rm /etc/nginx/sites-enabled/default


COPY /docker/setup_app_logs.sh /etc/my_init.d/10_setup_app_logs.sh.sh
# Startup script for generating nginx config that passes through env vars
COPY /docker/nginx_pass_environment.rb /etc/my_init.d/11_nginx_pass_environment.rb
COPY /docker/nginx_config_from_environment.rb /etc/my_init.d/12_nginx_config_from_environment.rb

RUN su app -c 'mkdir /home/app/{bundle,bundle-cache,webapp}'
WORKDIR /home/app/webapp

# Install bundle (assuming bundle packaged to vendor/cache)
ONBUILD COPY vendor/cache /home/app/bundle-cache/vendor/cache
ONBUILD COPY Gemfile /home/app/bundle-cache/Gemfile
ONBUILD COPY Gemfile.lock /home/app/bundle-cache/Gemfile.lock
ONBUILD RUN chown -R app /home/app/bundle-cache
ONBUILD RUN su app -c 'cd /home/app/bundle-cache && \
                       bundle install \
                            --jobs=4 \
                            --path=/home/app/bundle \
                            --no-cache'

ONBUILD COPY / /home/app/webapp
ONBUILD RUN cp -a /home/app/bundle-cache/.bundle /home/app/webapp
ONBUILD RUN mkdir -p log tmp public && chown --recursive app log tmp public
