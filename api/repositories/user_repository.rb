require 'mongo_mapper'
require 'bson'
require './api/models/user'

class UserRepository
  include Mongo
  include MongoMapper
  include BSON
  include SmartContract::Models

  def get_all_users
    User.all
  end

  def get_user(user_id)
    User.find user_id
  end

  def get_by_username(username)
    User.first(:username => username)
  end

  # def save_user(first_name, last_name, username, password_salt, password_hash)
  #   User.create(first_name:first_name,
  #                   last_name: last_name,
  #                   username: username,
  #                   password_salt: password_salt,
  #                   password_hash: password_hash)
  # end

  def save_user(username, role)
    User.create(username: username, role: role)
  end

  def delete_user(user_id)
    User.destroy(user_id)
  end
end