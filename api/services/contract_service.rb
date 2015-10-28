require './api/repositories/contract_repository'
require './api/services/signature_service'
require './api/services/queue_processor_service'
require './api/errors/contract_error'
require './api/constants/error_constants'
require './api/constants/contract_constants'

class ContractService
  include ErrorConstants::ContractErrors
  include GeneralConstants::ContractConstants

  def initialize(contract_repository = ContractRepository,
                 queue_service = QueueService,
                 signature_service = SignatureService)
    @contract_repository = contract_repository.new
    @signature_service = signature_service.new
    @queue_service = queue_service.new
  end

  def create_contract(data)
    user_id = data[:user_id]
    external_id = data[:external_id]
    name = data[:name]
    description = data[:description]
    expires = data[:expires]
    conditions = data[:conditions]
    participants = data[:participants]
    signatures = data[:signatures]

    @contract_repository.create_contract user_id, external_id, name, description, expires, conditions, participants, signatures
  end

  def get_contract(contract_id)
    @contract_repository.retrieve_contract contract_id
  end

  def get_contracts
    @contract_repository.retrieve_contracts
  end

  def get_contracts_lean
    @contract_repository.retrieve_contracts_lean
  end

  def get_contracts_by_user(user_id, lean = false)
    @contract_repository.retrieve_contracts_by_user(user_id, lean)
  end

  def sign_contract(contract_id, signature_id, signature_value, digest)

    # get the contract
    contract = get_contract contract_id
    raise ContractError, NO_CONTRACT_FOUND % contract_id if contract == nil

    # get the signature
    signature = find_signature contract, signature_id
    raise ContractError, NO_SIGNATURE_FOUND % signature_id if signature == nil

    # get the participant
    participant = find_participant_for_signature(contract, signature)
    raise ContractError, NO_PARTICIPANT_FOUND if participant == nil

    # check signature validity
    validate_signature(digest, participant[:public_key], signature_value)

    # update the signature
    update_ecdsa_signature signature, signature_value, digest

    # update the contract status if applicable
    set_contract_status contract

    # save the contract
    contract.save

    signature
  end

  # This method should only ever be called when the condition sig_mode='variable'
  # The participant who signs this will always be the ORACLE
  def create_condition_signature(contract_id, condition_id, signature_type, signature_value, digest)

    # get the contract; check if it is active
    contract = get_contract contract_id
    raise ContractError, NO_CONTRACT_FOUND % contract_id if contract == nil
    raise ContractError, INACTIVE_CONTRACT % contract_id unless is_contract_active contract

    # get the condition to be signed
    condition = find_condition contract, condition_id

    # get the participant on the condition - this should be the ORACLE
    participant = find_oracle_for_contract contract

    # confirm that the digest is correct based on the path
    validate_digest digest, "/contracts/#{contract_id}/conditions/#{condition_id}/signatures"

    # check signature validity
    validate_signature(digest, participant[:public_key], signature_value)

    signature = @contract_repository.create_signature_on_condition condition, participant.id.to_s, signature_type, signature_value, digest

    # confirm all condition signatures have been signed - if so, add trigger to queue
    if confirm_signature_count_matches_threshold condition
      @queue_service.add_trigger_to_queue contract_id, condition_id, condition.trigger.id
    end

    signature
  end

  def update_condition_signature(contract_id, condition_id, signature_id, signature_value, digest)

    # get the contract; check if it is active
    contract = get_contract contract_id
    raise ContractError, NO_CONTRACT_FOUND % contract_id if contract == nil
    raise ContractError, INACTIVE_CONTRACT % contract_id unless is_contract_active contract

    # get the condition to be signed
    condition = find_condition contract, condition_id

    # get the signature
    signature = find_signature condition, signature_id
    raise ContractError, NO_SIGNATURE_FOUND % signature_id if signature == nil

    # check the type of the signature
    type = signature.type

    case type
      when 'ecdsa'
        # get the participant
        participant = find_participant_for_signature(contract, signature)

        raise ContractError, NO_PARTICIPANT_FOUND if participant == nil

        # confirm that the digest is correct based on the path
        validate_digest digest, "/contracts/#{contract_id}/conditions/#{condition_id}/signatures/#{signature_id}"

        # check signature validity
        validate_signature(digest, participant[:public_key], signature_value)

        # if valid, then update
        update_ecdsa_signature(signature, signature_value, digest)

        # confirm all condition signatures have been signed - if so, add trigger to queue
        if confirm_all_condition_signatures condition
          @queue_service.add_trigger_to_queue contract_id, condition_id, condition.trigger.id
        end

        return signature
      when 'ss_key'
        # TODO:look up the relevant participant id associated with the delegate id and add ss_key to fragment array
        raise "Creation of signature with type 'ss_key' not implemented!"
      else
        raise ContractError, UNKNOWN_SIGNATURE_TYPE
    end
  end

  # def update_wallet_secret(contract_id, participant_id, secret_value)
  #   @contract_repository.update_wallet_secret contract_id, participant_id, secret_value
  # end

  #
  # HELPERS
  #

  private

  def find_condition(contract, condition_id)
    condition = contract.conditions.detect do |condition|
      condition_id == condition.id.to_s
    end

    raise ContractError, (NO_CONDITION_FOUND % condition_id) if condition == nil

    condition
  end

  def find_signature(item, signature_id)
    item.signatures.detect do |signature|
      signature_id == signature.id.to_s
    end
  end

  def find_participant_for_signature(contract, signature)
    contract.participants.detect do |participant|
      participant.id.to_s == signature.participant_id
    end
  end

  def find_oracle_for_contract(contract)
    # get the participant on the condition - this should be the ORACLE
    participant = contract.participants.detect do |item|
      item.roles.include? ROLE_ORACLE
    end

    raise ContractError, NO_ORACLE_ON_CONDITION if participant == nil

    participant
  end

  def validate_signature(digest, public_key, signature_value)
    raise ContractError, INVALID_SIGNATURE unless @signature_service.validate_signature digest, signature_value, public_key
  end

  def validate_digest(digest, undigested_data)
    raise ContractError, INVALID_DIGEST unless (HashGenerator.new.generate_hash undigested_data) == digest
  end

  def update_ecdsa_signature(signature, signature_value, digest)
    raise ContractError, SIGNATURE_ALREADY_RECORDED % signature.id.to_s if signature.value.to_s != ''
    # @contract_repository.update_signature(signature.id.to_s, signature_value, digest)

    signature.value = signature_value
    signature.digest = digest
    signature.save
  end

  def is_contract_active(contract)
    contract.status == 'active' ? true : false
  end

  def set_contract_status(contract)
    signature_count = 0

    contract.signatures.each do |signature|
      signature_count += 1 if (signature.value.to_s != '') && (signature.digest.to_s != '')
    end

    contract.status = 'active' if signature_count == contract.signatures.count
  end

  def confirm_signature_count_matches_threshold(condition)
    return false if condition.signatures.count < condition.sig_threshold

    condition.status = 'complete'
    condition.save
    true
  end

  def confirm_all_condition_signatures(condition)
    condition.signatures.each do |signature|
      return false if signature[:value].to_s == '' || signature[:digest].to_s == ''
    end

    condition.status = 'complete'
    condition.save
    true
  end
end