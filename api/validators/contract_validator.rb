class ContractValidator

  # new contracts don't require a signature
  def validate_new_contract(data)
    errors = []

    #fields
    errors.push 'Invalid transaction name' unless validate_string data[:name]
    errors.push 'Invalid transaction description' unless validate_string data[:description]
    errors.push 'Invalid transaction expires' unless validate_integer data[:expires]

    #arrays
    conditions_result = validate_new_conditions data[:conditions]
    transactions_result = validate_transactions data[:transactions]
    participants_result = validate_participants data[:participants]
    signatures_result = validate_new_signatures data[:signatures]

    errors.concat conditions_result
    errors.concat transactions_result
    errors.concat participants_result
    errors.concat signatures_result

    (errors.count > 0) ? {:valid => false, :errors => errors} : {:valid => true}

  end

  # new conditions don't yet need a signature
  def validate_new_conditions(conditions)
    result = []

    conditions.each do |condition|
      result << 'Invalid condition name' unless validate_string condition[:name]
      result << 'Invalid condition description' unless validate_string condition[:description]
      result << 'Invalid condition sequence number' unless validate_integer condition[:sequence_number]

      signature_result = validate_new_signatures condition[:signatures]
      trigger_result = validate_trigger condition[:trigger]

      result.concat signature_result
      result.concat trigger_result

    end

    result
  end

  def validate_updated_signature(signature)
    result << 'Invalid signature participant_id' unless validate_uuid signature[:participant_id]
    result << 'Invalid signature value' unless validate_string signature[:value]
    result << 'Invalid digest value' unless validate_string signature[:digest]

    (errors.count > 0) ? {:valid => false, :errors => errors} : {:valid => true}
  end

  # HELPERS

  def validate_new_signatures(signatures)
    result = []

    if (signatures == nil) || (signatures.count == 0)
      result << 'At least 1 signature is required!'
      return result
    end

    signatures.each do |signature|
      result << 'Invalid signature participant_external_id' unless validate_string signature[:participant_external_id].to_s
    end

    result
  end

  private
  def validate_participants(participants)
    result = []

    result << 'No participants found!' if participants == nil

    participants.each do |participant|
      result << 'Invalid participant external_id' unless validate_string participant[:external_id].to_s
      result << 'Invalid participant public key' unless validate_string participant[:public_key]
      result << 'Invalid participant role' unless validate_string participant[:role]
      #Note: wallet_address and wallet_tag are not required
    end if participants != nil

    result
  end

  private
  def validate_trigger(trigger)
    result = []

    result << 'No trigger found!' if trigger == nil

    result << 'At least one transaction or webhook must be present in the trigger!' if trigger == nil if trigger[:transactions] == nil && trigger[:webhooks == nil] if trigger[:transactions] != nil && trigger[:transactions].count > 0

    if trigger[:transactions] != nil && trigger[:transactions].count > 0
      result.concat validate_transactions trigger[:transactions]
    end

    if trigger[:webhooks] != nil && trigger[:webhooks].count > 0
      result.concat validate_webhooks trigger[:webhooks]
    end

    result
  end

  private
  def validate_transactions(transactions)
    result = []

    transactions.each do |transaction|
      result << 'Invalid transaction from_participant_external_id' unless validate_string transaction[:from_participant_external_id]
      result << 'Invalid transaction to_participant_external_id' unless validate_string transaction[:to_participant_external_id]
      result << 'Invalid transaction amount' unless validate_integer transaction[:amount]
      result << 'Invalid transaction currency' unless validate_string transaction[:currency]
    end if transactions != nil

    result
  end

  private
  def validate_webhooks(webhooks)
    result = []

    webhooks.each do |webhook|
      result << 'Invalid webhook for trigger' unless validate_string webhook[:uri]
    end

    result
  end

  private
  def validate_string(value)
    value.to_s != ''
  end

  private
  def validate_integer(value)
    Float(value) != nil rescue false
    end

  private
  def validate_uuid(value)
    value =~ /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
  end
end