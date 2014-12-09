module SmartContract
  module Models
    class Participant
      include MongoMapper::EmbeddedDocument

      key :external_id, Integer, :required => true
      key :public_key, String
      key :role, String, :required => true

      one :wallet, :class_name => 'SmartContract::Models::Wallet'

    end
  end
end