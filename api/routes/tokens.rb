require 'sinatra/base'
require './api/services/token_service'
require 'json'

module Sinatra
  module TokenRoutes
    def self.registered(app)

      #create new token: login
      # app.post '/tokens' do
      #   data = JSON.parse(request.body.read)
      #
      #   username = data['username']
      #   password = data['password']
      #
      #   if username.to_s != '' && password.to_s != ''
      #     token = TokenService.new.create_token username, password
      #
      #     if token == nil
      #       halt 401, 'Unauthorized!'
      #     end
      #
      #     {:user_id => token.user_id, :token => token.uuid}.to_json
      #
      #   else
      #     halt 401, 'Unauthorized!'
      #   end
      # end

      #create new token: login
      app.post '/tokens' do
        data = JSON.parse(request.body.read, :symbolize_names => true)

        auth = data[:auth]
        iv = data[:iv]

        if auth.to_s != '' && iv.to_s != ''
          token = TokenService.new.create_token auth, iv

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