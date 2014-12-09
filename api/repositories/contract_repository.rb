require 'mongo_mapper'
require 'bson'
require './api/utils/hash_generator'
require './api/models/contract'
require './api/models/participant'
require './api/models/wallet'
require './api/models/signature'
require './api/models/secret'
require './api/models/trigger'
require './api/models/condition'
require './api/models/transaction'
require './api/models/webhook'

class ContractRepository
  include Mongo
  include BSON
  include SmartContract::Models

  def get_contracts
    # db_contracts.find.to_a
    Contract.find_all
  end

  def get_contract(contract_id)
    # db_contracts.find({:contract_id => contract_id}).to_a[0]
    Contract.find_by_id contract_id
  end

  def get_contracts_by_status(status)
    # db_contracts.find({:status => status}).to_a
    Contract.find_by_status status
  end

  def save_contract(name, description, expires, conditions, participants, signatures)

    #see http://mongomapper.com/documentation/embedded-document.html

    ### PARTICIPANTS
    participant_ids_hash = {} #a dictionary of external_id:_id pairs
    participants_arr = create_participants_array(participants, participant_ids_hash)

    ### CONDITIONS
    conditions_arr = create_conditions_array(conditions, participant_ids_hash)

    ### SIGNATURES
    signature_arr = create_signatures_array(signatures, participant_ids_hash)

    ### CONTRACT
    Contract.create(:name => name,
                    :description => description,
                    :expires => expires,
                    :conditions => conditions_arr,
                    :participants => participants_arr,
                    :signatures => signature_arr)
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

  # Helpers

  private
  def create_signatures_array(signatures, participant_ids_hash)
    signature_arr = []

    signatures.each do |signature|
      participant_id = participant_ids_hash[signature[:participant_external_id]]

      signature_arr << Signature.new(:participant_id => participant_id,
                                     :value => signature[:value])
    end

    signature_arr
  end

  private
  def create_conditions_array(conditions, participant_ids_hash)
    conditions_arr = []

    conditions.each do |condition|

      ### SIGNATURES
      signature_arr = create_signature_array(condition, participant_ids_hash)

      ### TRIGGER
      trigger = create_trigger(condition, participant_ids_hash)

      ### CONDITION
      result = Condition.new(:name => condition[:name],
                             :description => condition[:description],
                             :sequence_number => condition[:sequence_number],
                             :expires => condition[:expires],
                             :status => 'pending',
                             :signatures => signature_arr,
                             :trigger => trigger)

      conditions_arr << result
    end

    conditions_arr
  end

  def create_signature_array(condition, participant_ids_hash)
    signature_arr = []

    condition[:signatures].each do |signature|
      participant_id = participant_ids_hash[signature[:participant_external_id].to_i]
      signature_arr << Signature.new(:participant_id => participant_id)
    end

    signature_arr
  end

  def create_trigger(condition, participant_ids_hash)
    transaction_arr = []
    webhook_arr = []

    ### TRANSACTIONS
    if condition[:trigger][:transactions] != nil && condition[:trigger][:transactions].count > 0
      condition[:trigger][:transactions].each do |transaction|
        from_participant_id = participant_ids_hash[transaction[:from_participant_external_id].to_i]
        to_participant_id = participant_ids_hash[transaction[:to_participant_external_id].to_i]

        transaction_arr << Transaction.new(:from_participant_id => from_participant_id,
                                           :to_participant_id => to_participant_id,
                                           :amount => transaction[:amount],
                                           :currency => transaction[:currency],
                                           :status => 'pending')
      end

    end

    ### WEBHOOKS
    if condition[:trigger][:webhooks] != nil && condition[:trigger][:webhooks].count > 0
      condition[:trigger][:webhooks].each do |webhook|
        webhook_arr << Webhook.new(:uri => webhook[:uri])
      end
    end

    Trigger.new(:transactions => transaction_arr, :webhooks => webhook_arr)
  end

  private
  def create_participants_array(participants, participant_ids_hash)
    participants_arr = []

    participants.each do |participant|
      participant_id = ObjectId.new
      #keep a record of the new ObjectId for each participant so that we can use this later
      participant_ids_hash[participant[:external_id].to_i] = participant_id

      result = Participant.new(:_id => participant_id,
                                    :external_id => participant[:external_id],
                                    :public_key => participant[:public_key],
                                    :role => participant[:role])
      ### WALLET
      if participant[:wallet] != nil
        result[:wallet] = create_wallet participant[:wallet]
      end

      participants_arr << participant
    end

    participants_arr
  end

  private
  def create_wallet(wallet)
    result = Wallet.new(:address => wallet[:address],
                        :destination_tag => wallet[:destination_tag])

    if wallet[:secret] != nil
      result[:secret] = Secret.new(:fragments => wallet[:secret][:fragments],
                                   :min_fragments => wallet[:secret][:min_fragments])
    end

    result

  end

  private
  def db_contracts
    Connection.new('localhost', 27017).db('ig-contracts')['contracts']
  end

end