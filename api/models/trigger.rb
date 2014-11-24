class Trigger
  include MongoMapper::EmbeddedDocument

  many :transactions
  many :webhooks

end