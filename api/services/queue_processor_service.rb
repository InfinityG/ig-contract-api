require './api/services/queue_service'
require './api/services/transaction_service'
require './api/services/webhook_service'

class QueueProcessorService

  # this will start a new thread which will periodically retrieve pending
  # triggers from the DB and attempt to process them
  def start
    @service_thread = Thread.new {

      queue_service = QueueService.new
      contract_service = ContractService.new
      webhook_service = WebHookService.new
      transaction_service = TransactionService.new

      while true

        begin
          pending_items = queue_service.get_pending_triggers

          pending_items.each do |queue_item|
            # get the contract
            contract = contract_service.get_contract queue_item.contract_id

            # get the condition
            current_condition = contract.conditions.detect do |condition|
              condition.id.to_s == queue_item.condition_id.to_s
            end

            # get the trigger for the condition
            current_trigger = current_condition.trigger

            # process transactions
            if (current_trigger.transactions != nil) && (current_trigger.transactions.count > 0)
              current_trigger.transactions.each do |transaction|

                # from participant
                from_participant = contract.participants.detect do |participant|
                  participant.id.to_s == transaction.from_participant_id.to_s
                  end

                # to participant
                to_participant = contract.participants.detect do |participant|
                  participant.id.to_s == transaction.to_participant_id.to_s
                end

                transaction_service.process_transaction transaction, from_participant, to_participant
              end
            end

            # process webhooks
            if (current_trigger.webhooks != nil) && (current_trigger.webhooks.count > 0)
              current_trigger.webhooks.each do |webhook|
                webhook_service.process_webhook webhook
              end
            end

            queue_service.update_queue_item queue_item.id, 'complete'
          end

        rescue Exception => e
          LOGGER.error "Error processing queue item! || Error: #{e}"
        end

        sleep 5.0
      end
    }
  end
end