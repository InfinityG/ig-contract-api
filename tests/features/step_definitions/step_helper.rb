require_relative '../../../api/utils/hash_generator'
require_relative '../../../api/utils/ecdsa_util'

require_relative '../../../tests/builders/participant_builder'
require_relative '../../../tests/builders/signature_builder'
require_relative '../../../tests/builders/trigger_builder'
require_relative '../../../tests/builders/contract_builder'
require_relative '../../../tests/builders/key_builder'
require_relative '../../../tests/builders/wallet_builder'
require_relative '../../../tests/builders/transaction_builder'
require_relative '../../../tests/builders/webhook_builder'
require_relative '../../../tests/builders/condition_builder'
require_relative '../../../tests/builders/contract_builder'
require_relative '../../../tests/builders/secret_builder'

class StepHelper

  def create_key_pair
    KeyBuilder.new.build_pair
  end

  def create_secret(fragments, threshold)
    SecretBuilder.new.with_fragments(fragments).with_threshold(threshold).build
  end

  def create_wallet(secret)
    WalletBuilder.new.with_address(HashGenerator.new.generate_uuid)
        .with_secret(secret).build
  end

  def create_participant(roles, external_id, key, wallet)
    ParticipantBuilder.new.with_roles(roles)
        .with_external_id(external_id)
        .with_public_key(key)
        .with_wallet(wallet)
        .build
  end

  def create_contract_signature(participant_external_id)
    SignatureBuilder.new.with_participant_external_id(participant_external_id).build
  end

  def create_updated_contract_signature(data, private_key)
    ecdsa_util = EcdsaUtil.new

    encoded_digest = HashGenerator.new.generate_hash data
    signature = ecdsa_util.sign encoded_digest, private_key
    encoded_signature = ecdsa_util.encode_signature signature

    SignatureBuilder.new.with_value(encoded_signature).with_digest(encoded_digest).build
  end

  def create_condition_signature(participant_external_id, type, delegated_by_id)
    SignatureBuilder.new.with_participant_external_id(participant_external_id)
        .with_type(type)
        .with_delegated_by_external_id(delegated_by_id)
        .build
  end

  def create_updated_condition_signature(data, private_key)
    ecdsa_util = EcdsaUtil.new

    encoded_digest = HashGenerator.new.generate_hash data
    signature = ecdsa_util.sign encoded_digest, private_key
    encoded_signature = ecdsa_util.encode_signature signature

    SignatureBuilder.new.with_value(encoded_signature).with_digest(encoded_digest).build
  end

  def create_webhook(uri)
    WebhookBuilder.new.with_uri(uri).build
  end

  def create_transaction(from_participant, to_participant, currency, amount)
    TransactionBuilder.new
        .with_from_participant_external_id(from_participant)
        .with_to_participant_external_id(to_participant)
        .with_currency(currency)
        .with_amount(amount)
        .build
  end

  def create_trigger(webhooks, transactions)
    TriggerBuilder.new
        .with_webhooks(webhooks)
        .with_transactions(transactions)
        .build
  end

  def create_condition(trigger, name, description, sequence_number, signatures, expires)
    ConditionBuilder.new
        .with_trigger(trigger)
        .with_name(name)
        .with_description(description)
        .with_sequence_number(sequence_number)
        .with_signatures(signatures)
        .with_expires(expires).build
  end

  def create_contract(name, description, expires, participants, conditions, signatures)
    ContractBuilder.new.with_name(name)
        .with_description(description)
        .with_expires(expires)
        .with_participants(participants)
        .with_conditions(conditions)
        .with_signatures(signatures)
        .build
  end
end