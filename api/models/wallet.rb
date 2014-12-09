module SmartContract
  module Models
    class Wallet
      include MongoMapper::EmbeddedDocument

      key :address, String
      key :destination_tag, String

      one :secret, :class_name => 'SmartContract::Models::Secret'
    end
  end
end