class Participant
  include MongoMapper::EmbeddedDocument

  key :external_id, Integer
  key :public_key, String
  key :wallet_address, String
  key :wallet_tag, Integer
  key :role, String

  one :master_signature
end