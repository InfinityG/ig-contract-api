require 'ig-crypto-utils'

require_relative '../../../api/utils/hash_generator'

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
  def create_canned_auth_payload
    # this is a canned auth payload that expires in Feb 2016
    # originally created on the ig-identity api from the following credentials:
    # {"username":"johnny_12bf79a3-a506-4ef6-9dd3-fd16841fd446@test.com","challenge":{"data":"YTFlYTI1ZTQtOTIxNy00YjcxLWJiY2QtNTA3MjU2MjUwNThj\n","signature":"MEYCIQDole8WqA283jpgumFUGGTIkxqNAGhFtbNK8vwnRCgTTwIhAIindJNr\n9c0UiClExmVMWXtNO3zLAHdqzbeNJDOdR4C7\n"},"domain":"www.testdomain.com"}
    '{"auth":"8Ia7Am2H+FgvqtKdVQ0VPACBUePAw98FIfYVFDB0W7A/BYpGLS5vNAcvTkuh\nHR/Grqo6Ty3G5wXAFHgIBfsSQymZ1OsQVrgm0uxV7Y5/veAEss4l9KdhBSvW\nSBgXOSr3IaHdUk1em4reyLZJD8qvOO1J+12BaZ7qAKtHxuY5kxr5AiY4dhVj\nK0jEdKYORAXCgvNjZss5QQHmwrrDrL/3NfYodkaXL43qwlo4mr6yjJBIlIB/\nvvI+/IMnBca2qxGn7uoprwovGRHBfLMX6dbWeUUWDFrwJZhhtLaU7tLeNQDK\nWsx1hO39Gfy4soGq3wdAi7vvToiLCtROordbs6HAjndhVa6PNuSAI0RmtKhD\nBoKBPGDT7ysmtkPZ9MlPifg4+V7eJruLrKMnKqjmecviTNE0y0a/wisS4jRv\nygF2k/N++WShAfk3yOHghPv93CDoMwQJDoJL/TUQ0MFfIIXjS8lkqDjwCv7P\ndEq7LWTnvsmn9hwWAc31i1y3D2j9XUaLL3CZx4/wvdcS8MPPxKNFWY35VbBH\nuvQMWV4ljGh8jxE=\n","iv":"rsesCGtNzHTLjmMoNjdnVQ==\n"}'
  end

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
    ecdsa_util = CryptoUtils::EcdsaUtil.new

    encoded_digest = HashGenerator.new.generate_hash data
    signature = ecdsa_util.sign encoded_digest, private_key

    SignatureBuilder.new.with_value(signature).with_digest(encoded_digest).build
  end

  def create_condition_signature(participant_external_id, type, delegated_by_id)
    SignatureBuilder.new.with_participant_external_id(participant_external_id)
        .with_type(type)
        .with_delegated_by_external_id(delegated_by_id)
        .build
  end

  def create_updated_condition_signature(data, private_key)
    ecdsa_util = CryptoUtils::EcdsaUtil.new

    encoded_digest = HashGenerator.new.generate_hash data
    signature = ecdsa_util.sign encoded_digest, private_key

    SignatureBuilder.new.with_value(signature).with_digest(encoded_digest).build
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