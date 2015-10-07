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
require './api/routes/users'
require './api/routes/tokens'
require './api/services/queue_processor_service'
require './api/services/config_service'

class ApiApp < Sinatra::Base

  #http://stackoverflow.com/questions/2362148/how-to-enable-ssl-for-a-standalone-sinatra-app
  def self.run!
    setup

    options = ConfigurationService.new.get_server_config

    # Signal.trap('INT') {
    #   Rack::Handler::WEBrick.shutdown
    # }

    # run ApiApp
    Rack::Handler::WEBrick.run self, options do |server|
      # Ctrl-C produces INT signal to stop
      [:INT, :TERM].each do |sig|
        trap(sig) do
          server.shutdown
        end
      end
    end
  end

  def self.setup
    # set the public folder
    # set :public_folder => config[:public_folder]
    setup_routes
    setup_database
    setup_queue_service
  end

  def self.setup_routes
    puts 'Setting up routes...'
    register Sinatra::CorsRoutes
    register Sinatra::AuthRoutes
    register Sinatra::DefaultRoutes
    register Sinatra::UserRoutes
    register Sinatra::TokenRoutes
    register Sinatra::ContractRoutes
  end

  def self.setup_database
    puts 'Setting up database...'
    config = ConfigurationService.new.get_config

    if config[:mongo_replicated] == 'true'
      MongoMapper.connection = Mongo::MongoReplicaSetClient.new([config[:mongo_host_1], config[:mongo_host_2], config[:mongo_host_3]])
    else
      conn_pair = config[:mongo_host_1].split(':')
      MongoMapper.connection = Mongo::MongoClient.new(conn_pair[0], conn_pair[1])
    end

    MongoMapper.database = config[:mongo_db]
  end

  def self.setup_queue_service
    puts 'Setting up queue service...'
    queue_service = QueueProcessorService.new
    queue_service.start
  end

end