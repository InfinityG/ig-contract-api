require './api/services/transaction_service'
require './api/services/webhook_service'

class TriggerService

  def initialize(transaction_service = TransactionService, webhook_service = WebHookService)
    @transaction_service = transaction_service.new
    @webhook_service = webhook_service.new
  end

  def process_trigger(trigger)

  end
end