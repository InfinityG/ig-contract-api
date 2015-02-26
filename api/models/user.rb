module SmartContract
  module Models
    class User
      include MongoMapper::Document

      key :username, String, :required => true, :key => true
      key :role, String, :required => true
    end
  end
end