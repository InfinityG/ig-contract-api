require 'sinatra/base'
require './api/services/config_service'
require './api/services/token_service'

module Sinatra
  module AuthRoutes
    def self.registered(app)

      #this filter applies to everything except registration of new users and documentation
      app.before do
        if (request.request_method == 'POST' && request.path_info == '/users') ||
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
            config = ConfigurationService.new.get_config

            # all other routes are the API - these require the api token
            if auth_header == nil || auth_header != config[:api_auth_token]
              halt 403, 'Unauthorized!'
            end
          end
        end
      end

    end
  end

  register AuthRoutes
end