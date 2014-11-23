class MasterSignature
  include MongoMapper::EmbeddedDocument

  key :signature, String
  key :participant_id, String, :required => true
end