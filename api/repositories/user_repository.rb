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

  def save_or_update_user(username, role)
    user = get_by_username(username)

    if user != nil
      user.role = role
      user.save
    else
      user = User.create(username: username, role: role)
    end

    user
  end

  def delete_user(user_id)
    User.destroy(user_id)
  end
end