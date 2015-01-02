module Sinatra
  module DefaultRoutes
    def self.registered(app)
      app.get '/' do
        redirect 'index.html'
      end
    end
  end
end