#config.ru
# see http://bundler.io/v1.3/sinatra.html

# require 'rubygems'
# require 'bundler'

# Bundler.require

require 'logger'
require './app'

#callback uri for completed contract notifications. Could use a queue here - eg: IronMQ
GATEWAY_WEBHOOK_URI = 'http://localhost:8001/notifications'

#logging
LOGGER = Logger.new 'app_log.log', 10, 1024000
DEFAULT_REQUEST_TIMEOUT = 60

#CORS origins
ALLOWED_ORIGIN = 'http://localhost:8001'

run ApiApp

# start this with 'rackup -p 8000' to start on port 8000