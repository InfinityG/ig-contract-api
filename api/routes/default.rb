module Sinatra
  module DefaultRoutes
    def self.registered(app)
      app.get '/' do
         send_file 'docs/index.html'
      end
    end
  end
end