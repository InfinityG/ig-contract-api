class MasterSignature
  include MongoMapper::EmbeddedDocument

  key :signature, String

  belongs_to :participant
end