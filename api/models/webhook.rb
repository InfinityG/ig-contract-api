class Webhook
  include MongoMapper::EmbeddedDocument

  key :uri, String
end