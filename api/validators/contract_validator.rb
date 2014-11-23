class ContractValidator
  def validate_contract(data)
    errors = []

    #fields
    errors.push 'Invalid transaction name' unless validate_string data[:name]
    errors.push 'Invalid transaction description' unless validate_string data[:description]
    errors.push 'Invalid transaction expires' unless validate_integer data[:expires]

    #arrays
    conditions_result = validate_conditions data[:conditions]
    transactions_result = validate_transactions data[:transactions]
    participants_result = validate_participants data[:participants]
    master_signatures_result = validate_master_signatures data[:master_signatures]

    errors.concat conditions_result
    errors.concat transactions_result
    errors.concat participants_result
    errors.concat master_signatures_result

    {:valid => false, :errors => errors}
  end

  def validate_conditions(conditions)
    result = []

    conditions.each do |condition|
      result << 'Invalid condition name' unless validate_string condition[:name]
      result << 'Invalid condition description' unless validate_string condition[:description]
      result << 'Invalid condition sequence number' unless validate_integer condition[:sequence_number]

      signatories_result = validate_signatories condition[:signatories]
      result.concat signatories_result
    end

    result
  end

  def validate_signatories(signatories)
    result = []

    result << 'No signatories found!' if signatories == nil

    signatories.each do |signatory|
      result << 'Invalid participant id' unless validate_integer signatory[:participant_id]
    end if signatories != nil

    result
  end

  def validate_participants(participants)
    result = []

    result << 'No participants found!' if participants == nil

    participants.each do |participant|
      result << 'Invalid participant external id' unless validate_integer participant[:external_id]
      result << 'Invalid participant public key' unless validate_integer participant[:public_key]
      result << 'Invalid participant role' unless validate_integer participant[:role]
      #Note: wallet_address and wallet_tag are not required
    end if participants != nil

    result
  end

  def validate_master_signatures(master_signatures)
    #TODO: check what we need to do here
    []
  end

  def validate_transactions(transactions)
    result = []

    transactions.each do |transaction|
      result << 'Invalid transaction from participant' unless validate_integer transaction[:from_participant]
      result << 'Invalid transaction to participant' unless validate_integer transaction[:to_participant]
      result << 'Invalid transaction amount' unless validate_integer transaction[:amount]
      result << 'Invalid transaction currency' unless validate_integer transaction[:currency]
    end if transactions != nil

    result
  end

  #Helpers
  def validate_string(value)
    value != nil && value != ''
  end

  def validate_integer(value)
    Float(value) != nil rescue false
  end
end