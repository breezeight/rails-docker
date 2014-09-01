# rails-docker Image

This image is supposed to serve as a base image for Rails applications following certain conventions. It's based on [Phusion's passenger-ruby21 image](https://github.com/phusion/passenger-docker).

## Assumptions

* Rails app is on the same level as Dockerfile (probably repository root)
* Gemfile and Gemfile.lock exist
* Before building, `bundle package --all` has been run, so at least all private Gems were put into `vendor/cache`. You might want to use a script like [prepare_docker_build.sh](example/prepare_docker_build.sh) to do this.

## Things this Dockerfile does

* **Configure nginx with passenger** to run a standard Rails app and respond on any hostname
    - Set `passenger_pre_start: http://localhost` to automatically issue a request to the Rails app and make it start as soon as nginx starts. Otherwise, the Rails app would be started on the first request, which then would take a while.
    - You can customize a part of the nginx configuration via environment variables. See 'nginx configuration via environment variables'.
* Make sure `webapp/logs` is writable by the Rails app (so you can mount a volume there without worrying about permissions)
* Add a startup script that configures **nginx to pass through all environment variables** to child processes (except HOME, HOSTNAME and PATH)
* Install libpq-dev for Postgres support
* Add quite a few **ONBUILD** instructions that do the following when building an application image based on this one:
    - Copy vendor/cache, Gemfile and Gemfile.lock into the image and install the bundle to /home/app/bundle
    - Put a .bundle/config into the webapp, so bundler finds the bundle and the bundle cache (for git dependencies)
    - Run `bundle install`
    - Copy the application to /home/app/webapp
    - Change the owners of `log`, `public` and `tmp` to the application user (`public` for possible asset precompilation)

## Usage

* The simplest Dockerfile you can use only uses a `FROM` instruction:

    ```shell
    FROM finnlabs/rails:latest

    # add custom instructions here
    ```

    This only works for simple applications without additional dependencies, e.g. for an application without database and and assets pipeline.

* You can find an **example Dockerfile**, prepare script and .dockerignore in [example/](example/).
* You can obviously replace and extend a lot in your application's Dockerfile, e.g.:
    - precompile assets
    - add a database.yml reading configuration from environment variables
    - add custom startup scripts to `/etc/my_init.d` - they're executed in alphabetical order and can be ordered by prefixing them with numbers
    - replace the default nginx configuration
    - install custom run-time dependencies via apt-get (Gem dependencies won't work as the ONBUILD instructions installing your Gems are always run before)
* If you want to run commands as the application user, use `su app -c '<command>'`.

## Configuration

### nginx configuration via environment variables

You can configure variables in the [http section](http://nginx.org/en/docs/http/ngx_http_core_module.html#http) of the nginx configuration via environment variables. These environment variables are read when starting the container, and written to a configuration file by [nginx_config_from_environment.rb](docker/nginx_config_from_environment.rb).

Use environment variables prefixed with `NGINX_HTTP_` followed by the nginx configuration parameter in uppercase.

Example: Setting `NGINX_HTTP_PASSENGER_MAX_POOL_SIZE=10` as environment variable via Docker would result in `passenger_max_pool_size 10;` being written to the nginx configuration.
