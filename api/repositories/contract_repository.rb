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

# CRUD operations on MongoDB

class ContractRepository
  include Mongo
  include MongoMapper
  include BSON
  include SmartContract::Models

  def retrieve_contracts
    # db_contracts.find.to_a
    Contract.all
  end

  def retrieve_contract(contract_id)
    Contract.find contract_id
  end

  def retrieve_contracts_by_status(status)
    Contract.find_by_status status
  end

  def retrieve_condition(condition_id)
    Condition.find condition_id
  end

  def create_contract(name, description, expires, conditions, participants, signatures)

    #see http://mongomapper.com/documentation/embedded-document.html

    ### PARTICIPANTS
    participants_arr = create_participants_array(participants)

    ### CONDITIONS
    conditions_arr = create_conditions_array(conditions, participants_arr)

    ### SIGNATURES
    signature_arr = create_signatures_array(signatures, participants_arr)

    ### CONTRACT
    Contract.create(name: name,
                    description: description,
                    expires: expires,
                    status: 'pending',
                    conditions: conditions_arr,
                    participants: participants_arr,
                    signatures: signature_arr)
  end

  # def get_participant(contract_id, participant_id)
  #   contract = retrieve_contract contract_id
  #
  #   contract.participants.detect do |participant|
  #     participant.id.to_s == participant_id
  #   end
  # end

  # update secret for wallet
  # we need to get the contract (instead of the secret only) so that we can be sure the correct secret is being updated for the correct wallet
  # def update_wallet_secret(contract_id, participant_id, secret_value)
  #   participant = get_participant contract_id, participant_id
  #
  #   if participant != nil && participant.wallet != nil
  #     if participant.wallet.secret != nil
  #       secret = participant.wallet.secret
  #       if secret.fragments.count < secret.min_fragments
  #         secret.fragments << secret_value
  #         secret.save
  #       end
  #     end
  #   else
  #     raise 'Could not find the wallet!'
  #   end
  # end

  # Helpers

  private
  def create_signatures_array(signatures, participants_arr)
    signature_arr = []

    signatures.each do |signature|
      participant_id = get_participant_id participants_arr, signature[:participant_external_id]

      signature_arr << Signature.new(participant_id: participant_id,
                                     value: signature[:value])
    end

    signature_arr
  end

  private
  def create_conditions_array(conditions, participants_arr)
    conditions_arr = []

    conditions.each do |condition|

      ### SIGNATURES
      signature_arr = create_signature_array(condition, participants_arr)

      ### TRIGGER
      trigger = create_trigger(condition, participants_arr)

      result = Condition.new(name: condition[:name],
                             description: condition[:description],
                             sequence_number: condition[:sequence_number],
                             expires: condition[:expires],
                             status: 'pending',
                             signatures: signature_arr,
                             trigger: trigger)

      conditions_arr << result
    end

    conditions_arr
  end

  private
  def create_signature_array(condition, participants_arr)
    signature_arr = []

    condition[:signatures].each do |signature|
      external_id = signature[:participant_external_id]
      type = signature[:type]
      participant_id = get_participant_id participants_arr, external_id
      signature_arr << Signature.new(:participant_id => participant_id.to_s,
                                     :type => type)
    end

    signature_arr
  end

  private
  def create_trigger(condition, participants)

    ### TRANSACTIONS
    transaction_arr = create_transaction_array(condition, participants)

    ### WEBHOOKS
    webhook_arr = create_webhook_array(condition)

    Trigger.new(:transactions => transaction_arr, :webhooks => webhook_arr)
  end

  private
  def create_webhook_array(condition)
    webhook_arr = []

    if condition[:trigger][:webhooks] != nil && condition[:trigger][:webhooks].count > 0
      condition[:trigger][:webhooks].each do |webhook|
        webhook_arr << Webhook.new(:uri => webhook[:uri])
      end
    end
    webhook_arr
  end

  private
  def create_transaction_array(condition, participants)
    transaction_arr = []

    if condition[:trigger][:transactions] != nil && condition[:trigger][:transactions].count > 0

      condition[:trigger][:transactions].each do |transaction|
        from_participant_id = get_participant_id participants, transaction[:from_participant_external_id].to_i
        to_participant_id = get_participant_id participants, transaction[:to_participant_external_id].to_i

        transaction_arr << Transaction.new(from_participant_id: from_participant_id,
                                           to_participant_id: to_participant_id,
                                           amount: transaction[:amount],
                                           currency: transaction[:currency],
                                           status: 'pending')
      end

    end

    transaction_arr
  end

  private
  def create_participants_array(participants)
    participants_arr = []

    participants.each do |participant|

      wallet = nil

      ### WALLET
      if participant[:wallet] != nil
        wallet = create_wallet participant[:wallet]
      end

      result = Participant.new(external_id: participant[:external_id],
                               public_key: participant[:public_key],
                               wallet: wallet,
                               roles: participant[:roles])

      participants_arr << result
    end

    participants_arr
  end

  private
  def create_wallet(wallet)
    result = Wallet.new(address: wallet[:address],
                        destination_tag: wallet[:destination_tag])

    if wallet[:secret] != nil
      result[:secret] = Secret.new(fragments: wallet[:secret][:fragments],
                                   min_fragments: wallet[:secret][:min_fragments])
    end

    result
  end

  private
  def get_participant_id(participants, external_id)
    participants.each do |participant|
      if participant[:external_id].to_s == external_id.to_s
        participant_id = participant[:_id]
        return participant_id
      end
    end

    nil
  end

  # private
  # def db_contracts
  #   Connection.new('localhost', 27017).db('ig-contracts')['contracts']
  # end

end