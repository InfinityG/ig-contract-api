module SmartContract
  module Models
    class User
      include MongoMapper::Document

      key :first_name, String, :required => true
      key :last_name, String, :required => true
      key :username, String, :required => true, :key => true
      key :password_hash, String
      key :password_salt, String
    end
  end
end