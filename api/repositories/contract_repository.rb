require 'mongo_mapper'
require 'bson'
require './api/utils/hash_generator'
require './api/models/contract'
require './api/models/participant'
require './api/models/master_signature'
require './api/models/signatory'
require './api/models/trigger'
require './api/models/condition'
require './api/models/transaction'
require './api/models/webhook'

class ContractRepository
  include Mongo
  include BSON

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

  def save_contract(name, description, expires, conditions, participants, master_signatures)
    # hash_generator = HashGenerator.new

    #see http://mongomapper.com/documentation/embedded-document.html

    ### PARTICIPANTS
    participants_arr = []
    participant_ids_hash = {} #a dictionary of external_id:_id pairs
    populate_participants(participant_ids_hash, participants, participants_arr)

    ### CONDITIONS
    conditions_arr = []
    populate_conditions(conditions, conditions_arr, participant_ids_hash)

    ### MASTER_SIGNATURES
    master_signature_arr = []
    populate_master_signatures(master_signature_arr, master_signatures, participant_ids_hash)


    ### CONTRACT
    Contract.create(:name => name,
                    :description => description,
                    :expires => expires,
                    :conditions => conditions_arr,
                    :participants => participants_arr,
                    :master_signatures => master_signature_arr)


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
  def populate_master_signatures(master_signature_arr, master_signatures, participant_ids_hash)
    master_signatures.each do |master_signature|
      participant_id = participant_ids_hash[master_signature[:participant_external_id]]

      master_signature_arr << MasterSignature.new(:participant_id => participant_id,
                                                  :signature => master_signature[:signature])
    end
  end

  private
  def populate_conditions(conditions, conditions_arr, participant_ids_hash)
    conditions.each do |condition|

      ### SIGNATORIES

      signatory_arr = []

      condition[:signatorys].each do |signatory|
        participant_id = participant_ids_hash[signatory[:participant_external_id].to_i]
        signatory_arr << Signatory.new(:participant_id => participant_id)
      end

      ### TRIGGER

      transaction_arr = []
      webhook_arr = []

      ### TRANSACTIONS
      condition[:trigger][:transactions].each do |transaction|
        from_participant_id = participant_ids_hash[transaction[:from_participant_external_id].to_i]
        to_participant_id = participant_ids_hash[transaction[:to_participant_external_id].to_i]

        transaction_arr << Transaction.new(:from_participant_id => from_participant_id,
                                           :to_participant_id => to_participant_id,
                                           :amount => transaction[:amount],
                                           :currency => transaction[:currency],
                                           :status => 'pending')
      end

      ### WEBHOOKS
      condition[:trigger][:webhooks].each do |webhook|
        webhook_arr << Webhook.new(:uri => webhook[:uri])
      end

      trigger = Trigger.new(:transactions => transaction_arr, :webhooks => webhook_arr)

      conditions_arr << Condition.new(:name => condition[:name],
                                      :description => condition[:description],
                                      :sequence_number => condition[:sequence_number],
                                      :status => 'pending',
                                      :trigger => trigger,
                                      :signatorys => signatory_arr)
    end


  end


  private
  def populate_participants(participant_ids_hash, participants, participants_arr)
    participants.each do |participant|
      participant_id = ObjectId.new
      #keep a record of the new ObjectId for each participant so that we can use this later
      participant_ids_hash[participant[:external_id].to_i] = participant_id

      participants_arr << Participant.new(:_id => participant_id,
                                          :external_id => participant[:external_id],
                                          :public_key => participant[:public_key],
                                          :wallet_address => participant[:wallet_address],
                                          :wallet_tag => participant[:wallet_tag],
                                          :role => participant[:role])
    end
  end


  private
  def db_contracts
    Connection.new('localhost', 27017).db('ig-contracts')['contracts']
  end
end