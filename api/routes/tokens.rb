require 'sinatra/base'
require './api/services/token_service'
require 'json'

module Sinatra
  module TokenRoutes
    def self.registered(app)

      #create new token: login
      app.post '/tokens' do
        data = JSON.parse(request.body.read)

        username = data['username']
        password = data['password']

        if username.to_s != '' && password.to_s != ''
          token = TokenService.new.create_token username, password

          if token == nil
            halt 401, 'Unauthorized!'
          end

          {:user_id => token.user_id, :token => token.uuid}.to_json

        else
          halt 401, 'Unauthorized!'
        end
      end

    end
  end
  register TokenRoutes
end