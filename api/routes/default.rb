require 'sinatra/base'

module Sinatra
  module DefaultRoutes
    def self.registered(app)
      app.get '/' do
        content_type 'text/html'
        cache_control :no_cache, :no_store, :must_revalidate, :max_age => 0

        File.new('docs/index.html').readlines
      end

      app.get '/stylesheets/:resource' do
        content_type 'text/css'
        File.new("docs/stylesheets/#{params[:resource]}").readlines
      end

      app.get '/fonts/:resource' do
        content_type 'application/x-font-ttf'
        File.new("docs/fonts/#{params[:resource]}").readlines
      end

      app.get '/images/:resource' do
        extension = params[:resource].split('.')[0]

        case extension
          when 'png'
            content_type 'image/png'
          when 'jpeg'
            content_type 'image/jpeg'
          else
            content_type 'image/gif'
        end

        File.new("docs/images/#{params[:resource]}").readlines
      end

      app.get '/javascripts/:resource' do
        content_type 'application/javascript'
        File.new("docs/javascripts/#{params[:resource]}").readlines
      end
    end
  end
end