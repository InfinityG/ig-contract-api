module SmartContract
  module Models
    class Signature
      include MongoMapper::EmbeddedDocument

      key :participant_id, String, :required => true
      key :delegated_by_id, String
      key :type, String
      key :value, String
      key :digest, String

    end
  end
end