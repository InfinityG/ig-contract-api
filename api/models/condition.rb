module SmartContract
  module Models
    class Condition
      include MongoMapper::EmbeddedDocument

      key :name, String, :required => true
      key :description, String, :required => true
      key :expires, Integer, :required => true
      key :sequence_number, Integer, :required => true
      key :status, String, :required => true

      one :trigger, :class_name => 'SmartContract::Models::Trigger'
      many :signatures, :class_name => 'SmartContract::Models::Signature'

    end
  end
end