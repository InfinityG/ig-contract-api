require 'sinatra/base'
require './api/services/token_service'

module Sinatra
  module AuthRoutes
    def self.registered(app)

      #this filter applies to everything except registration of new users and documentation
      app.before do
        if (request.request_method == 'POST' && request.path_info == '/users') ||
            (request.request_method == 'POST' && request.path_info == '/tokens') ||
            (request.request_method == 'GET' && request.path_info == '/')
          return
        else
          auth_header = env['HTTP_AUTHORIZATION']

          if auth_header == nil || auth_header != settings.admin_auth_token
            halt 403, 'Unauthorized!'
          end

          # if auth_header == nil || (TokenService.new.get_token(auth_header) == nil)
          #   halt 403, 'Unauthorized!'
          # end
        end
      end

    end
  end
  register AuthRoutes
end