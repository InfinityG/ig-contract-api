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
          auth_header = env['HTTP_AUTHORIZATION']

          is_static = lambda { |path|
            return true if path == '/'
            return true if path.include? '/fonts/'
            return true if path.include? '/stylesheets/'
            return true if path.include? '/javascripts/'
            return true if path.include? '/images/'
            false
          }

          # the default route will default to the docs - these need admin user/password access via basic auth
          if request.request_method == 'GET' && is_static.call(request.path_info)
            if auth_header == nil || auth_header != "Basic #{TokenService.new.get_admin_key}"
              headers['WWW-Authenticate'] = 'Basic realm="Restricted"'
              halt 401, 'Unauthorized!'
            end
          else
            # all other routes are the API - these require the api token
            if auth_header == nil
              halt 401, 'Unauthorized!'
            end

            token = TokenService.new.get_token(auth_header)
            if token == nil
              (halt 401, 'Unauthorized!')
            else
              user = UserService.new.get_by_id token[:user_id]

              @current_user_id = token[:user_id]
              @current_user_role = user[:role]
            end
          end
        end
      end

    end
  end

  register AuthRoutes
end