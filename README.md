# rails-docker Image

This image is supposed to serve as a base image for Rails applications following certain conventions.

## Assumptions

* Rails app is on the same level as Dockerfile (probably repository root)
* Gemfile and Gemfile.lock exist
* Before building, `bundle package --all` has been run, so at least all private Gems were put into `vendor/cache`. You might want to use a script like [example/prepare_docker_build.sh](prepare_docker_build.sh) to do this.

## Things this Dockerfile does

* **Configure nginx with passenger** to run a standard Rails app and respond on any hostname
* Make sure `webapp/logs` is writable by the Rails app (so you can mount a volume there without worrying about permissions)
* Add a startup script that configures **nginx to pass through all environment variables** to child processes (except HOME, HOSTNAME and PATH)
* Install libpq-dev for Postgres support
* Add quite a few **ONBUILD** instructions that do the following when building an application image based on this one:
    - Copy vendor/cache, Gemfile and Gemfile.lock into the image and install the bundle to /home/app/bundle
    - Copy the application to /home/app/webapp
    - Put a .bundle/config into the webapp, so bundler finds the bundle and the bundle cache (for git dependencies)

## Notes

* You can find an **example Dockerfile**, prepare script and .dockerignore in [example/](example/).
* You can obviously replace and extend a lot in your application's Dockerfile, e.g.:
    - add a database.yml reading configuration from environment variables
    - add custom startup scripts to `/etc/my_init.d` - they're executed in alphabetical order and can be ordered by prefixing them with numbers
    - replace the default nginx configuration
    - install custom run-time dependencies via apt-get (Gem dependencies won't work as the ONBUILD instructions installing your Gems are always run before)
