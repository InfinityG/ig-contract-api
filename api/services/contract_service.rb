require './api/repositories/contract_repository'
require './api/services/signature_service'
require './api/services/trigger_service'

class ContractService

  def initialize(contract_repository = ContractRepository, signature_service = SignatureService,
                 trigger_service = TriggerService)
    @contract_repository = contract_repository.new
    @signature_service = signature_service.new
    @trigger_service = trigger_service.new
  end

  ## CONTRACTS

  def create_contract(data)

    name = data[:name]
    description = data[:description]
    expires = data[:expires]
    conditions = data[:conditions]
    participants = data[:participants]
    signatures = data[:signatures]

    @contract_repository.save_contract name, description, expires, conditions, participants, signatures
  end

  def sign_contract(contract_id, signature_id, participant_id, signature_value, digest)

    # get the public key of the participant
    public_key = get_public_key(contract_id, participant_id)

    # check signature validity
    validate_signature(digest, public_key, signature_value)

    updated_contract = @contract_repository.update_contract_signature contract_id, signature_id, participant_id, signature_value, digest

    # update the contract status if all signatures have been gathered
    status = check_contract_status updated_contract

    if status == 'active'

    end

  end

  def check_contract_status(contract)
    contract[:signatures].each do |signature|
      unless (signature[:value] != nil && signature[:value] != '') && (signature[:digest] != nil && signature[:digest] != nil)
        return 'pending'
      end
    end

    'active'
  end

  def get_contract(contract_id)
    @contract_repository.get_contract contract_id
  end

  def get_contracts
    @contract_repository.get_contracts
  end

  ## CONDITIONS

  def sign_condition(contract_id, condition_id, signature_id, participant_id, signature_value, digest)

    # get the public key of the participant
    public_key = get_public_key(contract_id, participant_id)

    # check signature validity
    validate_signature(digest, public_key, signature_value)

    # if valid, then update
    updated_condition = @contract_repository.update_condition_signature(contract_id, condition_id, signature_id, participant_id,
                                          signature_value, digest)

    # process the trigger...
    @trigger_service.process_trigger updated_condition[:trigger]

    updated_condition
  end

  # HELPERS

  private
  def validate_signature(digest, public_key, signature_value)
    unless @signature_service.validate_cryptocoin_js_signature digest, signature_value, public_key
      raise 'Signature could not be verified!'
    end
  end

  private
  def get_public_key(contract_id, participant_id)
    participant = @contract_repository.get_participant contract_id, participant_id
    participant[:public_key]
  end
end