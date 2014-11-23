class Participant
  include MongoMapper::EmbeddedDocument

  key :external_id, Integer, :required => true
  key :public_key, String
  key :wallet_address, String
  key :wallet_tag, Integer
  key :role, String, :required => true

end