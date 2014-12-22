class TriggerBuilder

  def initialize
    @transactions_arr = []
    @webhooks_arr = []
  end

  def with_transactions(transactions)
    @transactions_arr.concat transactions
    self
    end

  def with_transaction(transaction)
    @transactions_arr << transaction
    self
  end

  def with_webhooks(webhooks)
    @webhooks_arr.concat webhooks
    self
  end

  def with_webhook(webhook)
    @webhooks_arr << webhook
    self
  end

  def build
    {:transactions => @transactions_arr, :webhooks => @webhooks_arr}
  end

end