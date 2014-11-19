require 'sinatra/base'
require './api/routes/cors'
require './api/routes/contracts'

class ApiApp < Sinatra::Base

  #register routes
  #register Sinatra::AuthRoutes
  register Sinatra::CorsRoutes
  register Sinatra::ContractRoutes

end