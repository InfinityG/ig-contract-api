module SmartContract
  module Models
    class Signature
      include MongoMapper::EmbeddedDocument

      key :participant_id, String, :required => true
      key :value, String
      key :digest, String

    end
  end
end