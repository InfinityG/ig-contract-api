module SmartContract
  module Models
    class Condition
      include MongoMapper::EmbeddedDocument

      key :name, String, :required => true
      key :description, String, :required => true
      key :expires, Integer, :required => true
      key :sequence_number, Integer, :required => true
      key :status, String, :required => true

      key :sig_mode, String, :required => true  # allowed values: 'fixed', 'variable'
      key :sig_threshold, Integer
      key :sig_weight, Integer

      many :signatures, :class_name => 'SmartContract::Models::Signature'

      one :trigger, :class_name => 'SmartContract::Models::Trigger'

    end
  end
end