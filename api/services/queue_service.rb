require './api/repositories/queue_repository'

class QueueService

  def initialize(trigger_repository = QueueRepository)
    @queue_repository = trigger_repository.new
  end

  def add_trigger_to_queue(contract_id, condition_id, trigger_id)
    @queue_repository.create_queue_item contract_id, condition_id, trigger_id
  end

  def get_pending_triggers
    @queue_repository.get_pending_queue_items
  end
end