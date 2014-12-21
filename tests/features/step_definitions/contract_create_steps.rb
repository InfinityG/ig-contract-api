require_relative '../../../api/utils/hash_generator'
require_relative '../../../api/utils/rest_util'

require_relative '../../../api/utils/ecdsa_util'

require_relative '../../features/step_definitions/builders/participant_builder'
require_relative '../../features/step_definitions/builders/signature_builder'
require_relative '../../features/step_definitions/builders/trigger_builder'
require_relative '../../features/step_definitions/builders/contract_builder'
require_relative '../../features/step_definitions/builders/key_builder'

require 'json'
require 'minitest'

Given(/^I have the following participants:$/) do |table|
  # table is a table.hashes.keys # => [:role_type]

  @participants_arr = []
  @all_keys = []

  generator = HashGenerator.new

  table.hashes.each do |item|
    # external_id = generator.generate_random_number
    external_id = item[:external_id]

    key_hash = KeyBuilder.new.with_participant_external_id(external_id).build_hash
    @all_keys << key_hash

    wallet = nil
    # TODO: complete wallet
    if item[:has_wallet]
      wallet = WalletBuilder.new.with_address(generator.generate_uuid).build
    end

    participant = ParticipantBuilder.new.with_roles(item[:role_types])
                      .with_external_id(external_id)
                      .with_public_key(key_hash[external_id][:pk])
                      .with_wallet(wallet)
                      .build

    @participants_arr << participant
  end
end

Given(/^I have no participants$/) do
  @participants_arr = nil
end

And(/^I have contract signatures from the following participants:$/) do |table|
  @contract_signatures_arr = []

  table.hashes.each do |item|
    participant = @participants_arr.detect do |participant|
      participant[:external_id] == item[:external_id]
    end

    @contract_signatures_arr << SignatureBuilder.new.with_participant_external_id(participant[:external_id]).build
  end

end

And(/^I have (\d+) conditions$/) do |arg|
  @condition_count = arg.to_i
  @condition_signatures_hash = {}
  @condition_expiry_hash = {}
  @condition_webhooks_hash = {}
  @condition_transactions_hash = {}

  i = 0
  while i < arg.to_i do
    i += 1
    @condition_signatures_hash[i] = []
    @condition_expiry_hash[i] = nil
    @condition_webhooks_hash[i] = []
    @condition_transactions_hash[i] = []
  end

end

And(/^condition (\d+) has the following signatures:$/) do |arg, table|
  # table is a table.hashes.keys # => [:type, :participant_id]

  table.hashes.each do |item|
    @condition_signatures_hash[arg.to_i] << SignatureBuilder.new.with_participant_external_id(item[:participant_id]).with_type(item[:type]).build
  end
end

And(/^condition (\d+) has an expiry of (\d+)$/) do |arg1, arg2|
  @condition_expiry_hash[arg1.to_i] = arg2
end

And(/^condition (\d+) has the following webhooks:$/) do |arg, table|
  table.hashes.each do |item|
    @condition_webhooks_hash[arg.to_i] << WebhookBuilder.new.with_uri(item[:uri]).build
  end
end

And(/^condition (\d+) has the following transactions:$/) do |arg, table|
  table.hashes.each do |item|
    @condition_transactions_hash[arg.to_i] << TransactionBuilder.new
                                             .with_from_participant_external_id(item[:from_participant])
                                             .with_to_participant_external_id(item[:from_participant])
                                             .with_currency(item[:currency])
                                             .with_amount(item[:amount])
                                             .build
  end
end

And(/^I have no contract signature$/) do
  @contract_signatures_arr = nil
end

And(/^the contract expiry date is (\d+)$/) do |arg|
  @contract_expires = arg
end

When(/^I POST the contract to the API$/) do

  conditions_arr = []

  i = 0
  while i < @condition_count do

    i += 1
    trigger = TriggerBuilder.new
                  .with_webhooks(@condition_webhooks_hash[i])
                  .with_transactions(@condition_transactions_hash[i])
                  .build

    conditions_arr << ConditionBuilder.new
                          .with_trigger(trigger)
                          .with_name("Test condition #{i}")
                          .with_description("Test condition #{i} description")
                          .with_sequence_number(i)
                          .with_signatures(@condition_signatures_hash[i])
                          .with_expires(@condition_expiry_hash[i]).build
  end

  contract = ContractBuilder.new.with_name('Test contract 1')
                 .with_description('Test contract 1 description')
                 .with_expires(@contract_expires)
                 .with_participants(@participants_arr)
                 .with_conditions(conditions_arr)
                 .with_signatures(@contract_signatures_arr)
                 .build

  rest_client = RestUtil.new
  @result = rest_client.execute_post 'http://localhost:9000/contracts', contract.to_json

end

Then(/^the API should respond with a (\d+) response code$/) do |arg|
  assert @result.response_code.to_s == arg
end
