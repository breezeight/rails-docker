#!/usr/bin/env ruby

EXCLUDED_KEYS = %w(HOME HOSTNAME PATH)

keys = (ENV.keys.sort - EXCLUDED_KEYS).map { |key| "env #{key};" }.join("\n")

puts 'Passing through these environment variables to nginx child processes:'
puts keys

File.open('/etc/nginx/main.d/webapp-env.conf', 'w') do |file|
  file.write("# environment variables to be passed through to nginx child processes\n")
  file.write("# automatically generated during container startup by nginx_environment.rb\n")
  file.write(keys)
end
