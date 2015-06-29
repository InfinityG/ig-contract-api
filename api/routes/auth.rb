require 'sinatra/base'
require './api/services/config_service'
require './api/services/token_service'

module Sinatra
  module AuthRoutes
    def self.registered(app)

      #this filter applies to everything except options, registration of new users and documentation
      app.before do
        if (request.request_method == 'OPTIONS') ||
            (request.request_method == 'POST' && request.path_info == '/users') ||
            (request.request_method == 'POST' && request.path_info == '/tokens')
          return
        else
          is_static = lambda { |path|
            return true if path == '/'
            return true if path == '/favicon.ico'
            return true if path.include? '/docs'
            return true if path.include? '/fonts/'
            return true if path.include? '/css/'
            return true if path.include? '/js/'
            return true if path.include? '/images/'
            false
          }

          unless is_static.call(request.path_info)
            auth_header = env['HTTP_AUTHORIZATION']

            if auth_header == nil || auth_header != TokenService.new.get_admin_key
              halt 401, 'Unauthorized!'
            end
          end
        end
      end

    end
  end

  register AuthRoutes
end