module SmartContract
  module Models
    class Secret
      include MongoMapper::EmbeddedDocument

      key :threshold, Integer
      key :fragments, Array
    end
    end
  end