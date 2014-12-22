require_relative '../../../api/utils/rest_util'
require_relative '../../../tests/features/step_definitions/step_helper'

require 'json'
require 'minitest'

Given(/^I have the following participants:$/) do |table|
  @step_helper = StepHelper.new

  @participants_arr = []
  @all_keys = []

  table.hashes.each do |item|
    external_id = item[:external_id]

    key_hash = @step_helper.create_key_hash external_id
    @all_keys << key_hash

    wallet = nil
    wallet = @step_helper.create_wallet if item[:has_wallet]
    participant = @step_helper.create_participant(item[:role_types], external_id, key_hash[external_id][:pk], wallet)

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

    @contract_signatures_arr << @step_helper.create_contract_signature(participant[:external_id])
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
  table.hashes.each do |item|
    @condition_signatures_hash[arg.to_i] << @step_helper.create_condition_signature(item[:participant_id],
                                                                                    item[:type],
                                                                                    item[:delegated_by])
  end
end

And(/^condition (\d+) has an expiry of (\d+)$/) do |arg1, arg2|
  @condition_expiry_hash[arg1.to_i] = arg2.to_i
end

And(/^condition (\d+) has the following webhooks:$/) do |arg, table|
  table.hashes.each do |item|
    @condition_webhooks_hash[arg.to_i] << @step_helper.create_webhook(item[:uri])
  end
end

And(/^condition (\d+) has the following transactions:$/) do |arg, table|
  table.hashes.each do |item|
    @condition_transactions_hash[arg.to_i] << @step_helper.create_transaction(item[:from_participant],
                                                                              item[:to_participant],
                                                                              item[:currency],
                                                                              item[:amount])
  end
end

And(/^I have no contract signature$/) do
  @contract_signatures_arr = nil
end

And(/^the contract expiry date is (\d+)$/) do |arg|
  @contract_expires = arg.to_i
end

When(/^I POST the contract to the API$/) do

  conditions_arr = []

  i = 0
  while i < @condition_count do

    i += 1
    trigger = @step_helper.create_trigger(@condition_webhooks_hash[i], @condition_transactions_hash[i])

    conditions_arr << @step_helper.create_condition(trigger, "Test condition #{i}", "Test condition #{i} description",
                                                    i, @condition_signatures_hash[i], @condition_expiry_hash[i])

  end

  contract = @step_helper.create_contract('Test contract 1', 'Test contract 1 description', @contract_expires,
                                          @participants_arr, conditions_arr, @contract_signatures_arr)

  rest_client = RestUtil.new
  @result = rest_client.execute_post 'http://localhost:9000/contracts', contract.to_json

end

Then(/^the API should respond with a (\d+) response code$/) do |arg|
  assert @result.response_code.to_s == arg
end

def get_result
  @result
end
