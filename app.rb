require 'sinatra/base'
require './api/routes/cors'
require './api/routes/contracts'
require './api/services/queue_processor_service'

class ApiApp < Sinatra::Base

  #register routes
  #register Sinatra::AuthRoutes
  register Sinatra::CorsRoutes
  register Sinatra::ContractRoutes

  #Configure MongoMapper
  MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
  MongoMapper.database = 'ig-contracts'

  #start the queue service for triggers...
  queue_service = QueueProcessorService.new
  queue_service.start

end