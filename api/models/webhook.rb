module SmartContract
  module Models
    class Webhook
      include MongoMapper::EmbeddedDocument

      key :uri, String
    end
  end
end