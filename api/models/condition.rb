class Condition
  include MongoMapper::EmbeddedDocument

  key :name, String, :required => true
  key :description, String, :required => true
  key :expires, Integer, :required => true
  key :sequence_number, Integer, :required => true
  key :status, String, :required => true

  many :transactions
  many :signatorys

end