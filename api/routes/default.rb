require 'sinatra/base'

module Sinatra
  module DefaultRoutes
    def self.registered(app)
      app.get '/' do
        content_type 'text/html'
        cache_control :no_cache, :no_store, :must_revalidate, :max_age => 0

        File.new('designer/www/index.html').readlines
      end

      app.get '/css/:resource' do
        content_type 'text/css'
        File.new("designer/www/css/#{params[:resource]}").readlines
      end

      app.get '/fonts/:resource' do
        content_type 'application/x-font-ttf'
        File.new("designer/www/fonts/#{params[:resource]}").readlines
      end

      app.get '/images/:resource' do
        extension = params[:resource].split('.')[1]

        case extension
          when 'png'
            content_type 'image/png'
          when 'jpeg'
            content_type 'image/jpeg'
          when 'svg'
            content_type 'image/svg+xml'
          when 'ico'
            content_type 'text/html'
          else
            content_type 'image/gif'
        end

        File.new("designer/www/images/#{params[:resource]}").readlines
      end

      app.get '/js/:resource' do
        content_type 'application/javascript'
        File.new("designer/www/js/#{params[:resource]}").readlines
      end
    end
  end
end