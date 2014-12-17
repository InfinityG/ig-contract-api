module SmartContract
  module Models
    class QueueItem
      include MongoMapper::Document

      key :contract_id, String, :required => true
      key :condition_id, String, :required => true
      key :trigger_id, String, :required => true
      key :status, String, :required => true

      timestamps!

    end
  end
end