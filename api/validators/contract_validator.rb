require 'date'
require 'json'
require 'ig-validator-utils'

require './api/errors/validation_error'
require './api/constants/contract_constants'
require './api/constants/error_constants'

class ContractValidator
  include ValidatorUtils
  include ErrorConstants::ValidationErrors
  include GeneralConstants::ContractConstants

  def validate_user_details(data)
    errors = []

    if data == nil
      errors.push NO_DATA_FOUND
    else
      #fields
      errors.push INVALID_EXTERNAL_USER_ID unless GeneralValidator.validate_string data[:id]

      unless GeneralValidator.validate_email data[:email]
        errors.push INVALID_EMAIL
      end if data[:email].to_s != ''

      errors.push INVALID_FIRST_NAME unless GeneralValidator.validate_string data[:first_name]
      errors.push INVALID_LAST_NAME unless GeneralValidator.validate_string data[:last_name]
      errors.push INVALID_USERNAME unless GeneralValidator.validate_string data[:username]

      raise ValidationError, {:valid => false, :errors => errors}.to_json if errors.count > 0
    end
  end

  # new contracts don't require a signature
  def validate_new_contract(data)
    errors = []

    #fields
    errors.push INVALID_CONTRACT_NAME unless GeneralValidator.validate_string data[:name]
    errors.push INVALID_CONTRACT_DESCRIPTION unless GeneralValidator.validate_string data[:description]
    errors.push INVALID_CONTRACT_EXPIRY unless GeneralValidator.validate_unix_datetime data[:expires]

    #arrays
    conditions_result = validate_new_conditions data[:conditions], data[:participants]
    transactions_result = validate_transactions data[:transactions]
    participants_result = validate_participants data[:participants]
    signatures_result = validate_new_contract_signatures data[:signatures]

    errors.concat conditions_result
    errors.concat transactions_result
    errors.concat participants_result
    errors.concat signatures_result

    raise ValidationError, {:valid => false, :errors => errors}.to_json if errors.count > 0
  end

  def validate_updated_signature(signature)
    errors = []

    # errors.push 'Invalid signature participant_id' unless validate_hex signature[:participant_id]
    errors.push INVALID_SIGNATURE_VALUE unless GeneralValidator.validate_string signature[:value]
    errors.push INVALID_DIGEST_VALUE unless GeneralValidator.validate_string signature[:digest]

    raise ValidationError, {:valid => false, :errors => errors}.to_json if errors.count > 0
    end

  def validate_new_signature(signature)
    errors = []

    # errors.push 'Invalid signature participant_id' unless validate_hex signature[:participant_id]
    errors << INVALID_PARTICIPANT_CONDITION_SIGNATURE unless GeneralValidator.validate_string signature[:participant_external_id].to_s
    errors << INVALID_CONDITION_SIGNATURE_TYPE unless GeneralValidator.validate_string signature[:type].to_s
    errors << INVALID_SIGNATURE_VALUE unless GeneralValidator.validate_string signature[:value]
    errors << INVALID_DIGEST_VALUE unless GeneralValidator.validate_string signature[:digest]

    raise ValidationError, {:valid => false, :errors => errors}.to_json if errors.count > 0
  end

  private
  def validate_new_conditions(conditions, participants)
    result = []

    conditions.each do |condition|
      result << INVALID_CONDITION_NAME unless GeneralValidator.validate_string condition[:name]
      result << INVALID_CONDITION_DESCRIPTION unless GeneralValidator.validate_string condition[:description]
      result << INVALID_CONDITION_SEQUENCE unless GeneralValidator.validate_integer condition[:sequence_number]
      result << INVALID_CONDITION_EXPIRY unless GeneralValidator.validate_unix_datetime condition[:expires]
      result << INVALID_CONDITION_SIGNATURE_MODE unless SIGNATURE_MODES.include? condition[:sig_mode].to_s.downcase

      signature_result = validate_new_condition_signatures condition[:sig_mode], condition[:signatures], participants

      trigger_result = validate_trigger condition[:trigger]

      result.concat signature_result
      result.concat trigger_result
    end

    result
  end

  private
  def validate_new_contract_signatures(signatures)
    result = []

    result.concat validate_new_signatures signatures

    signatures.each do |signature|
      result << INVALID_PARTICIPANT_CONTRACT_SIGNATURE unless GeneralValidator.validate_string signature[:participant_external_id].to_s
    end if signatures != nil

    result
  end

  private
  def validate_new_condition_signatures(sig_mode, signatures, participants)
    result = []

    # If sig_mode='static' then the request must contain a fixed number of pre-populated (without signature values and digests)
    # signatures. If sig_mode='dynamic', then there should be NO signatures, just an empty array. This is because we expect
    # new signatures to be posted to the condition with signature values and digests already populated.
    case sig_mode
      when SIGNATURE_MODE_STATIC
        result.concat validate_new_signatures signatures

        signatures.each do |signature|
          result << INVALID_PARTICIPANT_CONDITION_SIGNATURE unless GeneralValidator.validate_string signature[:participant_external_id].to_s
          result << INVALID_CONDITION_SIGNATURE_TYPE unless GeneralValidator.validate_string signature[:type].to_s

          if signature[:type].to_s == SHARED_SECRET
            result.concat(validate_delegated_participant(signature[:delegated_by_external_id], participants))
          end

        end if signatures != nil
      when SIGNATURE_MODE_DYNAMIC
        result << INVALID_CONDITION_SIGNATURE_COUNT unless (signatures == nil || signatures.length == 0)
      else
        # type code here
    end

    result
  end

  private
  def validate_delegated_participant(delegated_participant_id, participants)
    result = []

    if delegated_participant_id.to_s != ''
      delegate = participants.detect do |participant|
        participant[:external_id].to_s == delegated_participant_id.to_s
      end

      result << INVALID_DELEGATED_PARTICIPANT unless delegate != nil
      result << INVALID_SECRET_THRESHOLD unless delegate[:wallet][:secret][:threshold] > 1
      result << INVALID_SECRET_FRAGMENT_LENGTH unless delegate[:wallet][:secret][:fragments].count >= 1
    end

    result
  end

  private
  def validate_new_signatures(signatures)
    result = []

    if (signatures == nil) || (signatures.count == 0)
      result << SIGNATURE_REQUIRED
    end

    result
  end

  private
  def validate_participants(participants)
    result = []

    result << 'No participants found!' if participants == nil

    participants.each do |participant|
      result << INVALID_PARTICIPANT_EXTERNAL_ID unless GeneralValidator.validate_string participant[:external_id].to_s
      result << INVALID_PARTICIPANT_PUBLIC_KEY unless GeneralValidator.validate_string participant[:public_key]

      (participant[:roles] == nil || participant[:roles].count == 0) ?
          result << INVALID_PARTICIPANT_ROLE :
          participant[:roles].each do |role|
            result << INVALID_PARTICIPANT_ROLE unless (GeneralValidator.validate_string role && ROLES.include?(role))
          end

      #Note: wallet_address and wallet_tag are not required
    end if participants != nil

    result
  end

  private
  def validate_trigger(trigger)
    result = []

    result << NO_TRIGGER_FOUND if trigger == nil

    result << TRANSACTION_OR_WEBHOOK_IN_TRIGGER if trigger == nil if trigger[:transactions] == nil && trigger[:webhooks == nil] if trigger[:transactions] != nil && trigger[:transactions].count > 0

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
      result << INVALID_TRANSACTION_FROM_PARTICIPANT unless GeneralValidator.validate_string transaction[:from_participant_external_id]
      result << INVALID_TRANSACTION_TO_PARTICIPANT unless GeneralValidator.validate_string transaction[:to_participant_external_id]
      result << INVALID_TRANSACTION_AMOUNT unless GeneralValidator.validate_integer transaction[:amount]
      result << INVALID_TRANSACTION_CURRENCY unless GeneralValidator.validate_string transaction[:currency]
    end if transactions != nil

    result
  end

  private
  def validate_webhooks(webhooks)
    result = []

    webhooks.each do |webhook|
      result << INVALID_WEBHOOK unless GeneralValidator.validate_string webhook[:uri]
    end

    result
  end

end