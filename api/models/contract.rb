module SmartContract
  module Models
    class Contract

      include MongoMapper::Document

      key :name, String, :required => true
      key :description, String, :required => true
      key :expires, Integer, :required => true
      key :status, String, :required => true

      many :conditions, :class_name => 'SmartContract::Models::Condition'
      many :participants, :class_name => 'SmartContract::Models::Participant'
      many :signatures, :class_name => 'SmartContract::Models::Signature'

    end
  end
end