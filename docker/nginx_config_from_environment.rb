#!/usr/bin/env ruby

DEFAULT_NGINX_HTTP_CONFIG = {
  'passenger_pre_start' => 'http://localhost'
}

def main
  File.open('/etc/nginx/conf.d/config_via_environment.conf', 'w') do |file|
    file.write(format_nginx_vars(
                DEFAULT_NGINX_HTTP_CONFIG.merge(
                  env_vars_with_prefix_stripped('NGINX_HTTP_'))))
  end
end

def env_vars_with_prefix_stripped(prefix)
  ENV.each_pair.select { |k, _| k.start_with? prefix }
     .map { |k, v| [k[prefix.length..-1], v] }.to_h
end

def format_nginx_vars(var_hash)
  var_hash.each_pair.map { |k, v| "#{k.downcase} #{v};" }.join("\n")
end

main
