class TransactionBuilder

  def with_from_participant_external_id(id)
    @from_participant_external_id = id
    self
  end

  def with_to_participant_external_id(id)
    @to_participant_external_id = id
    self
  end

  def with_amount(amount)
    @amount = amount
    self
  end

  def with_currency(currency)
    @currency = currency
    self
  end

  def build
    {
        :from_participant_external_id => @from_participant_external_id,
        :to_participant_external_id => @to_participant_external_id,
        :amount => @amount,
        :currency => @currency
    }
  end

end