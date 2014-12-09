module SmartContract
  module Models
    class Secret
      include MongoMapper::EmbeddedDocument

      key :min_fragments, Integer
      key :fragments, Array
    end
    end
  end