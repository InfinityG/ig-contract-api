require 'sinatra/base'
require 'logger'
require 'mongo'
require 'mongo_mapper'

require './api/routes/cors'
require './api/routes/default'
require './api/routes/contracts'
require './api/services/queue_processor_service'

class ApiApp < Sinatra::Base

  def self.start
    # Register routes
    #register Sinatra::AuthRoutes
    register Sinatra::DefaultRoutes
    register Sinatra::CorsRoutes
    register Sinatra::ContractRoutes

    # Configure MongoMapper
    MongoMapper.connection = Mongo::Connection.new(settings.mongo_host, settings.mongo_port)
    MongoMapper.database = settings.mongo_db

    # Start the queue service for triggers...
    queue_service = QueueProcessorService.new
    queue_service.start
  end

  configure :development do
    # Global constants
    LOGGER = Logger.new 'app_log.log', 10, 1024000

    set(:mongo_host => 'localhost')
    set(:mongo_port => 27017)
    set(:mongo_db => 'ig-contracts')
    set(:logger_file => 'app_log.log')
    set(:logger_age => 10)
    set(:logger_size => 1024000)
    set(:default_request_timeout => 60)
    set(:allowed_origin => 'localhost')

    set(:static => true)
    set(:public_folder => 'docs')

    start
    end

  configure :test do
    # Global constants
    LOGGER = Logger.new 'app_log.log', 10, 1024000

    set(:mongo_host => 'localhost')
    set(:mongo_port => 27017)
    set(:mongo_db => 'ig-contracts')
    set(:logger_file => 'app_log.log')
    set(:logger_age => 10)
    set(:logger_size => 1024000)
    set(:default_request_timeout => 60)
    set(:allowed_origin => 'localhost')

    start
  end

  configure :production do
    # Global constants
    LOGGER = Logger.new 'app_log.log', 10, 1024000

    set(:mongo_host => 'localhost')
    set(:mongo_port => 27017)
    set(:mongo_db => 'ig-contracts')
    set(:logger_file => 'app_log.log')
    set(:logger_age => 10)
    set(:logger_size => 1024000)
    set(:default_request_timeout => 60)
    set(:allowed_origin => 'localhost')

    start
  end

end