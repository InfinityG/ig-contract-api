#config.ru
# see http://bundler.io/v1.3/sinatra.html

# require 'rubygems'
# require 'bundler'

# Bundler.require

require './app'
require 'webrick'
require './api/services/config_service'

options = ConfigurationService.new.get_server_config

# run ApiApp
Rack::Handler::WEBrick.run ApiApp, options do |server|
  [:INT, :TERM].each do |sig|
    trap(sig) do
      server.shutdown
    end
  end
end

# start this with 'rackup -p 9000' to start on port 9000
# start this with 'rackup -p 9000 -E development' to start on port 9000, for development environment