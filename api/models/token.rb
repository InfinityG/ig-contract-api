module SmartContract
  module Models
    class Token
      include MongoMapper::Document

      key :user_id, Integer
      key :uuid, String,  :key => true
      key :expires, Integer
    end
  end
end