require 'mongo_mapper'
require 'bson'
require './api/models/queue_item'

class QueueRepository
  include Mongo
  include MongoMapper
  include BSON
  include SmartContract::Models

  def create_queue_item(contract_id, condition_id, trigger_id)
    QueueItem.create(:contract_id => contract_id,
                            :condition_id => condition_id,
                            :trigger_id => trigger_id,
                            :status => 'pending')
  end

  def get_pending_queue_items
    QueueItem.all(:status => 'pending', :order => :created_at.asc)
  end

  def update_queue_item(queue_item_id, status)
    item = QueueItem.find queue_item_id

    if item != nil
      item.status = status
      item.save
    else
      raise "TiggerQueueItem with id #{queue_item_id} not found!"
    end
  end
end