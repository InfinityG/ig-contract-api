require './api/repositories/contract_repository'
require './api/services/signature_service'
require './api/services/queue_processor_service'
require './api/errors/contract_error'
require './api/constants/error_constants'

class ContractService
  include ErrorConstants::ContractErrors

  def initialize(contract_repository = ContractRepository,
                 queue_service = QueueService,
                 signature_service = SignatureService)
    @contract_repository = contract_repository.new
    @signature_service = signature_service.new
    @queue_service = queue_service.new
  end

  def create_contract(data)
    external_id = data[:external_id]
    name = data[:name]
    description = data[:description]
    expires = data[:expires]
    conditions = data[:conditions]
    participants = data[:participants]
    signatures = data[:signatures]

    @contract_repository.create_contract external_id,  name, description, expires, conditions, participants, signatures
  end

  def get_contract(contract_id)
    @contract_repository.retrieve_contract contract_id
  end

  def get_contracts
    @contract_repository.retrieve_contracts
  end

  def get_contracts_by_user(user_id)
    @contract_repository.retrieve_contracts_by_user(user_id)
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

  def sign_condition(contract_id, condition_id, signature_id, signature_value, digest)

    # get the contract; check if it is active
    contract = get_contract contract_id
    raise ContractError, NO_CONTRACT_FOUND % contract_id if contract == nil
    raise ContractError, INACTIVE_CONTRACT % contract_id unless is_contract_active contract

    # get the condition to be signed
    condition = find_condition contract, condition_id
    raise ContractError, NO_CONDITION_FOUND % condition_id if condition == nil

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

        # check signature validity
        validate_signature(digest, participant[:public_key], signature_value)

        # if valid, then update
        update_ecdsa_signature(signature, signature_value, digest)

        # confirm all condition signatures have been signed - if so, add trigger to queue
        @queue_service.add_trigger_to_queue contract_id, condition_id, condition.trigger.id if confirm_all_condition_signatures condition

        return signature
      when 'ss_key'
        # TODO:look up the relevant participant id associated with the delegate id and add ss_key to fragment array
        raise 'Not implemented!'
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
    contract.conditions.detect do |condition|
      condition_id == condition.id.to_s
    end
  end

  private
  def find_signature(item, signature_id)
    item.signatures.detect do |signature|
      signature_id == signature.id.to_s
    end
  end

  private
  def find_participant_for_signature(contract, signature)
    contract.participants.detect do |participant|
      participant.id.to_s == signature.participant_id
    end
  end

  private
  def validate_signature(digest, public_key, signature_value)
    unless @signature_service.validate_signature digest, signature_value, public_key
      raise 'Signature could not be verified!'
    end
  end

  private
  def update_ecdsa_signature(signature, signature_value, digest)
    signature.value = signature_value
    signature.digest = digest
    signature.save
  end

  def is_contract_active(contract)
    contract.status == 'active' ? true : false
  end

  private
  def set_contract_status(contract)
    signature_count = 0

    contract.signatures.each do |signature|
      signature_count += 1 if (signature.value.to_s != '') && (signature.digest.to_s != '')
    end

    contract.status = 'active' if signature_count == contract.signatures.count
  end

  private
  def confirm_all_condition_signatures(condition)
    condition.signatures.each do |signature|
      if signature[:value].to_s == '' || signature[:digest].to_s == ''
        return false
      end
    end
    true
  end
end