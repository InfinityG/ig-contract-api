require './api/repositories/contract_repository'

class ContractService
  def create_contract(name, description, expires, target_wallet_address,
                      target_wallet_tag, value, conditions)
    repository = ContractRepository.new
    repository.save_contract name, description, expires, target_wallet_address, target_wallet_tag, value, conditions
  end

  def get_contract(contract_id)
    repository = ContractRepository.new
    repository.get_contract contract_id
  end

  def get_contracts
    repository = ContractRepository.new
    repository.get_contracts
  end
end