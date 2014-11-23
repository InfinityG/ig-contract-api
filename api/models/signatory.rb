class Signatory
  include MongoMapper::EmbeddedDocument

  key :participant_id, String, :required => true
  key :signature, String
end