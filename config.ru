#config.ru
# see http://bundler.io/v1.3/sinatra.html

# require 'rubygems'
# require 'bundler'

# Bundler.require

require './app'

run ApiApp

# start this with 'rackup -p 9000' to start on port 9000
# start this with 'rackup -p 9000 -E development' to start on port 9000, for development environment