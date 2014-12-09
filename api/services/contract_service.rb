require './api/repositories/contract_repository'

class ContractService
  def create_contract(data)

    name = data[:name]
    description = data[:description]
    expires = data[:expires]
    conditions = data[:conditions]
    participants = data[:participants]
    signatures = data[:signatures]

    repository = ContractRepository.new
    repository.save_contract name, description, expires, conditions, participants, signatures
  end

  def get_contract(contract_id)
    repository = ContractRepository.new
    repository.get_contract contract_id
  end

  def get_contracts
    repository = ContractRepository.new
    repository.get_contracts
  end

  def update_condition(contract_id, condition_id, signature_id, signature, status)
    repository = ContractRepository.new
    repository.update_signature(contract_id, condition_id, signature_id, signature, status)
  end
end