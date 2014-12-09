module SmartContract
  module Models
    class Trigger
      include MongoMapper::EmbeddedDocument

      many :transactions, :class_name => 'SmartContract::Models::Transaction'
      many :webhooks, :class_name => 'SmartContract::Models::Webhook'

    end
  end
end