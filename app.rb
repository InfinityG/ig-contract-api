require 'sinatra/base'
require 'openssl'
require 'webrick'
require 'webrick/https'
require 'logger'
require 'mongo'
require 'mongo_mapper'

require './api/routes/cors'
require './api/routes/default'
require './api/routes/contracts'
require './api/services/queue_processor_service'
require './api/services/config_service'

class ApiApp < Sinatra::Base

  configure do

    config = ConfigurationService.new.get_config

    # Register routes
    #register Sinatra::AuthRoutes
    self.register Sinatra::DefaultRoutes
    self.register Sinatra::CorsRoutes
    self.register Sinatra::ContractRoutes

    # Configure MongoMapper
    host = (config[:mongo_host] == 'localhost') ? config[:mongo_host] : "#{config[:mongo_user]}:#{config[:mongo_password]}@#{config[:mongo_host]}"

    MongoMapper.connection = Mongo::MongoClient.new(host, config[:mongo_port])
    MongoMapper.database = config[:mongo_db]

    # Start the queue service for triggers...
    queue_service = QueueProcessorService.new
    queue_service.start
  end

end