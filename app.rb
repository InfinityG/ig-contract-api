require 'sinatra/base'
require 'data_mapper'
require 'dm-sqlite-adapter'
require './api/routes/cors'
require './api/routes/contracts'

class ApiApp < Sinatra::Base

  #register routes
  #register Sinatra::AuthRoutes
  register Sinatra::CorsRoutes
  register Sinatra::ContractRoutes

  #set up database connection
  DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite")
  DataMapper.finalize
  DataMapper.auto_migrate!  #creates the tables on first use

end