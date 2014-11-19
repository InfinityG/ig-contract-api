require './api/utils/hash_generator'
require 'mongo'

class ContractRepository
  include Mongo

  def get_contracts
    db_contracts.find.to_a
  end

  def get_contract(contract_id)
    db_contracts.find({:contract_id => contract_id}).to_a[0]
  end

  def get_contracts_by_status(status)
    db_contracts.find({:status => status}).to_a
  end

  def save_contract(name, description, expires, target_wallet_address, target_wallet_tag, value, conditions)
    hash_generator = HashGenerator.new

    conditions.each do |condition|
      condition[:id] = hash_generator.generate_uuid
      condition[:status] = 'pending'
      condition[:signatures].each do |signature|
        signature[:id] = hash_generator.generate_uuid
      end
    end

    contract = {
        :contract_id => hash_generator.generate_uuid,
        :name => name,
        :description => description,
        :expires => expires,
        :target_wallet_address => target_wallet_address,
        :target_wallet_tag => target_wallet_tag,
        :value => value,
        :conditions => conditions,
        :status => 'pending'
    }

    contracts = db_contracts
    contracts.insert(contract)
    contract[:contract_id]

  end

  def update_signature(contract_id, condition_id, signature_id, signature, status)
    contracts = db_contracts
    contract = contracts.find({:contract_id => contract_id}).to_a[0]

    contract['conditions'].each do |condition|
      if condition['id'] == condition_id
        condition['signatures'].each do |sig|
          if sig['id'] == signature_id
            sig['signature'] = signature
            sig['status'] = status
          end
        end
      end
    end

    contracts.update({:contract_id => contract['contract_id']}, contract)

  end

  private
  def db_contracts
    Connection.new('localhost', 27017).db('ig-contracts')['contracts']
  end
end