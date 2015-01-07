require 'sinatra/base'
require 'openssl'
require 'webrick'
require 'webrick/https'
require 'logger'
require 'mongo'
require 'mongo_mapper'

require './api/routes/cors'
require './api/routes/default'
require './api/routes/auth'
require './api/routes/contracts'
require './api/services/queue_processor_service'
require './api/services/config_service'

class ApiApp < Sinatra::Base

  configure do

    # set the global configuration constants (settings)
    config = ConfigurationService.new.get_config
    set config

    # Register routes
    register Sinatra::AuthRoutes
    register Sinatra::DefaultRoutes
    register Sinatra::CorsRoutes
    register Sinatra::ContractRoutes

    # Configure MongoMapper
    MongoMapper.connection = Mongo::MongoClient.new(settings.mongo_host, settings.mongo_port)
    MongoMapper.database = settings.mongo_db

    if config[:mongo_host] != 'localhost'
      MongoMapper.database.authenticate(settings.mongo_db_user, settings.mongo_db_password)
    end

    # Start the queue service for triggers...
    queue_service = QueueProcessorService.new
    queue_service.start
  end

end