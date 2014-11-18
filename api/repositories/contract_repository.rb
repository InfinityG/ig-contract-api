require './api/models/contract'
require './api/models/condition'
require './api/models/signature'
require './api/utils/hash_generator'

class ContractRepository
  def get_contracts
    Contract.all
  end

  def get_contract(contract_id)
    contract = Contract.all(:id => contract_id).first
    conditions = Condition.all(:contract_uuid => contract.uuid)

    conditions.each do |condition|
      condition.signatures.each do |signature|
        signature
      end
      contract.conditions << condition
    end

    contract
  end

  def get_contracts_by_status(status)
    Contract.all(:status => status)
  end

  def save_contract(name, description, expires, target_wallet_address, target_wallet_tag, value, conditions)
    hash_generator = HashGenerator.new

    contract = Contract.new(
        :uuid => hash_generator.generate_uuid,
        :name => name,
        :description => description,
        :expires => expires,
        :target_wallet_address => target_wallet_address,
        :target_wallet_tag => target_wallet_tag,
        :value => value,
        :status => 'pending')

    if conditions != nil && conditions.length > 0
      conditions.each do |cond|
        condition = Condition.new(:uuid => hash_generator.generate_uuid,
                                  :name => cond['name'],
                                  :description => cond['description'],
                                  :sequence_number => cond['sequence_number'],
                                  :expires => cond['expires'])

        # if conditions['signatures'] != nil
        cond['signatures'].each do |sig|
          condition.signatures << Signature.new(:uuid => hash_generator.generate_uuid,
                                                :origin_wallet_address => sig['origin_wallet_address'],
                                                :origin_wallet_tag => sig['origin_wallet_tag'])
        end
        # end

        contract.conditions << condition
      end
    end

    begin
      contract.save
      contract
    rescue Exception => e
      # contract.errors.each do |e|
      puts e
      raise e
    end
  end

end