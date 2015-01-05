require 'openssl'

module ConfigurationConstants
  module Environments
    DEVELOPMENT = {
        :host => 'localhost',
        :port => 9000,
        :mongo_host => 'localhost',
        :mongo_port => 27017,
        :mongo_db => 'ig-contracts',
        :logger_file => 'app_log.log',
        :logger_age => 10,
        :logger_size => 1024000,
        :default_request_timeout => 60,
        :allowed_origin => 'localhost',
        :static => true,
        :public_folder => 'docs'
    }

    TEST = {
        :host => '10.0.0.208',
        :port => 9000,
        :ssl_cert_path => '/etc/ssl/certs/server.crt',
        :ssl_private_key_path => '/etc/ssl/private/server.key',
        :mongo_host => '10.0.1.46',
        :mongo_port => 27017,
        :mongo_db => 'contracts',
        :mongo_db_user => 'contractsUser',
        :mongo_db_password => 'l3tsagr33T0th1s!',
        :logger_file => 'app_log.log',
        :logger_age => 10,
        :logger_size => 1024000,
        :default_request_timeout => 60,
        :allowed_origin => 'localhost',
        :static => true,
        :public_folder => 'docs'
    }

    PRODUCTION = {
        :host => '10.0.0.208',
        :port => 9000,
        :ssl_cert_path => '/etc/ssl/certs/server.crt',
        :ssl_private_key_path => '/etc/ssl/private/server.key',
        :mongo_host => '10.0.1.46',
        :mongo_port => 27017,
        :mongo_db => 'contracts',
        :mongo_db_user => 'contractsUser',
        :mongo_db_password => 'l3tsagr33T0th1s!',
        :logger_file => 'app_log.log',
        :logger_age => 10,
        :logger_size => 1024000,
        :default_request_timeout => 60,
        :allowed_origin => 'localhost',
        :static => true,
        :public_folder => 'docs'
    }
  end
end