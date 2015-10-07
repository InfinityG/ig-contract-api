require 'openssl'

module ConfigurationConstants
  module Environments
    DEVELOPMENT = {
        :host => '0.0.0.0',
        :port => 8002,
        :api_auth_token => ENV['API_AUTH_TOKEN'],
        :shared_aes_key => ENV['SHARED_AES_KEY'],
        :id_provider_public_ecdsa_key => ENV['ID_IO_PUBLIC_KEY'],
        :mongo_replicated => ENV['MONGO_REPLICATED'],
        :mongo_host_1 => ENV['MONGO_HOST_1'],
        :mongo_host_2 => nil,
        :mongo_host_3 => nil,
        :mongo_db => ENV['MONGO_DB'],
        :logger_file => 'app_log.log',
        :logger_age => 10,
        :logger_size => 1024000,
        :default_request_timeout => 60,
        :allowed_origin => '*'
    }

    TEST = {
        :host => '0.0.0.0',
        :port => 8002,
        :api_auth_token => ENV['API_AUTH_TOKEN'],
        :shared_aes_key => ENV['SHARED_AES_KEY'],
        :id_provider_public_ecdsa_key => ENV['ID_IO_PUBLIC_KEY'],
        :mongo_replicated => ENV['MONGO_REPLICATED'],
        :mongo_host_1 => ENV['MONGO_HOST_1'],
        :mongo_host_2 => ENV['MONGO_HOST_2'],
        :mongo_host_3 => ENV['MONGO_HOST_3'],
        :mongo_db => ENV['MONGO_DB'],
        :logger_file => 'app_log.log',
        :logger_age => 10,
        :logger_size => 1024000,
        :default_request_timeout => 60,
        :allowed_origin => '*'
    }

    PRODUCTION = {
        :host => '0.0.0.0',
        :port => 8002,
        :api_auth_token => ENV['API_AUTH_TOKEN'],
        :shared_aes_key => ENV['SHARED_AES_KEY'],
        :id_provider_public_ecdsa_key => ENV['ID_IO_PUBLIC_KEY'],
        :mongo_replicated => ENV['MONGO_REPLICATED'],
        :mongo_host_1 => ENV['MONGO_HOST_1'],
        :mongo_host_2 => ENV['MONGO_HOST_2'],
        :mongo_host_3 => ENV['MONGO_HOST_3'],
        :mongo_db => ENV['MONGO_DB'],
        :logger_file => 'app_log.log',
        :logger_age => 10,
        :logger_size => 1024000,
        :default_request_timeout => 60,
        :allowed_origin => '*'
    }
  end
end