class Condition
  include MongoMapper::EmbeddedDocument

  key :_id, BSON::ObjectId
  key :name, String
  key :description, String
  key :expires, Integer
  key :sequence_number, Integer
  key :status, String

  many :transactions
  many :signatorys

end