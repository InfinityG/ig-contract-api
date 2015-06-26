require 'sinatra/base'

module Sinatra
  module DefaultRoutes
    def self.registered(app)

      ################
      ### Designer ###
      ################

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

      ############
      ### Docs ###
      ############

      app.get '/docs' do
        content_type 'text/html'
        cache_control :no_cache, :no_store, :must_revalidate, :max_age => 0

        File.new('docs/build/index.html').readlines
      end

      app.get '/docs/stylesheets/:resource' do
        content_type 'text/css'
        File.new("docs/build/stylesheets/#{params[:resource]}").readlines
      end

      app.get '/docs/fonts/:resource' do
        content_type 'application/x-font-ttf'
        File.new("docs/build/fonts/#{params[:resource]}").readlines
      end

      app.get '/docs/images/:resource' do
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

        File.new("docs/build/images/#{params[:resource]}").readlines
      end

      app.get '/docs/javascripts/:resource' do
        content_type 'application/javascript'
        File.new("docs/build/javascripts/#{params[:resource]}").readlines
      end
    end
  end
end