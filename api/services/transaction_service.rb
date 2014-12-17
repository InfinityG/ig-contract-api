require './api/services/webhook_service'
require './api/services/shared_secret_service'
require './api/services/contract_service'
require './api/utils/rest_util'

class TransactionService

  def initialize(rest_util = RestUtil,
                 secret_service = SharedSecretService)
    @rest_util = rest_util.new
    @shared_secret_service = secret_service.new
  end

  def process_transaction(transaction, from_participant, to_participant)
    # TODO: parse transaction; reassemble shared secret (if applicable); execute POST request to payment gateway


  end
end