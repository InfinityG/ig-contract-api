
class Signatory
  include MongoMapper::EmbeddedDocument

  key :participant_id, String
end