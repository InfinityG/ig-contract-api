require_relative '../../../tests/config'
require_relative '../../../api/utils/rest_util'
require_relative '../../../tests/features/step_definitions/step_helper'

require 'json'
require 'minitest'

Given(/^I have the following participants:$/) do |table|
  @step_helper = StepHelper.new

  @participants_hash = {}
  @all_keys_hash = {}

  table.hashes.each do |item|
    external_id = item[:external_id]

    @all_keys_hash[external_id] = @step_helper.create_key_pair

    @participants_hash[external_id] = {:roles => item[:role_types].split(','),
                                       :public_key => @all_keys_hash[external_id][:pk]}

  end
end

And(/^I have the following wallets:$/) do |table|
  table.hashes.each do |item|
    external_id = item[:participant_id]

    secret = nil

    if item[:secret_threshold].to_i > 0
      secret_value = @all_keys_hash[external_id][:sk]
      secret = @step_helper.create_secret([secret_value], item[:secret_threshold].to_i)
    end

    wallet = @step_helper.create_wallet(secret)

    @participants_hash[external_id][:wallet] = wallet
  end
end

Given(/^I have no participants$/) do
  @participants_hash = nil
end

And(/^I have contract signatures from the following participants:$/) do |table|
  @contract_signatures_arr = []

  table.hashes.each do |item|
    @contract_signatures_arr << @step_helper.create_contract_signature(item[:participant_id])
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

And(/^condition (\d+) has an expiry of (\d+) days from now$/) do |arg1, arg2|
  unix_date = get_unix_date arg2.to_i
  @condition_expiry_hash[arg1.to_i] = unix_date
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

And(/^the contract expiry date is (\d+) days from now$/) do |arg|
  unix_date = get_unix_date arg.to_i
  @contract_expires = unix_date
end

And(/^I have a valid auth token on the API$/) do
   auth = @step_helper.create_canned_auth_payload

   rest_client = RestUtil.new
   result = rest_client.execute_post "#{CONTRACT_API_URI}/tokens", '', auth
   parsed_result = JSON.parse(result.response_body, :symbolize_names => true)

  @auth_token = parsed_result[:token]
end

When(/^I POST the contract to the API$/) do

  participants_arr = []

  @participants_hash.each do |id, item|
    participants_arr << @step_helper.create_participant(item[:roles], id, item[:public_key], item[:wallet])
  end

  conditions_arr = []

  i = 0
  while i < @condition_count do

    i += 1
    trigger = @step_helper.create_trigger(@condition_webhooks_hash[i], @condition_transactions_hash[i])

    conditions_arr << @step_helper.create_condition(trigger, "Test condition #{i}", "Test condition #{i} description",
                                                    i, @condition_signatures_hash[i], @condition_expiry_hash[i])

  end

  contract = @step_helper.create_contract('Test contract 1', 'Test contract 1 description', @contract_expires,
                                          participants_arr, conditions_arr, @contract_signatures_arr)

  rest_client = RestUtil.new
  @result = rest_client.execute_post "#{CONTRACT_API_URI}/contracts", @auth_token, contract.to_json

end

Then(/^the API should respond with a (\d+) response code$/) do |arg|
  assert @result.response_code.to_s == arg
end

Given(/^I have an existing contract$/) do
  steps '
    Given I have the following participants:
      | external_id | role_types |
      | 1           | initiator    |
      | 2           | oracle     |
      | 3           | sender      |
      | 4           | receiver      |
    And I have the following wallets:
      | participant_id | secret_threshold |
      | 3              | 1                |
      | 4              | 0                |
    And I have contract signatures from the following participants:
      | participant_id |
      | 2           |
    And the contract expiry date is 2 days from now
    And I have 1 conditions
    And condition 1 has the following signatures:
      | type  | participant_id | delegated_by |
      | ecdsa | 2              |              |
    And condition 1 has an expiry of 3 days from now
    And condition 1 has the following webhooks:
      | uri                |
      | www.mywebhook1.com |
      | www.mywebhook2.com |
    And I have a valid auth token on the API
    And I POST the contract to the API
  '
end

When(/^I sign the contract$/) do
  @result = sign_contract
end

And(/^The contract state is "([^"]*)"/) do |arg|
  if arg == 'active'
    sign_contract
  end
end

When(/^I sign a condition$/) do

  contract = JSON.parse(@result.response_body, :symbolize_names => true)
  contract_id = contract[:id]
  condition = contract[:conditions][0]
  condition_id = condition[:id]
  condition_signature = condition[:signatures][0]
  signature_id = condition_signature[:id]

  signer = contract[:participants].detect do |participant|
    participant[:id] == condition_signature[:participant_id]
  end

  signer_id = signer[:external_id].to_s

  # get the secret key for signing
  secret_key = @all_keys_hash[signer_id][:sk]

  # create the signature payload
  signature = @step_helper.create_updated_condition_signature contract.to_json, secret_key

  # execute the request: /contracts/{id}/conditions/{id}/signatures/{id}
  rest_client = RestUtil.new
  @result = rest_client.execute_post "#{CONTRACT_API_URI}/contracts/#{contract_id}/conditions/#{condition_id}/signatures/#{signature_id}",
                                     @auth_token,
                                     signature.to_json

end

private
def sign_contract
  contract = JSON.parse(@result.response_body, :symbolize_names => true)
  contract_id = contract[:id]
  contract_signature = contract[:signatures][0]
  signature_id = contract_signature[:id]

  signer = contract[:participants].detect do |participant|
    participant[:id] == contract_signature[:participant_id]
  end

  signer_id = signer[:external_id].to_s

  # get the secret key for signing
  secret_key = @all_keys_hash[signer_id][:sk]

  # create the signature payload
  signature = @step_helper.create_updated_contract_signature contract.to_json, secret_key

  # execute the request: /contracts/{id}/signatures/{id}
  rest_client = RestUtil.new
  rest_client.execute_post "#{CONTRACT_API_URI}/contracts/#{contract_id}/signatures/#{signature_id}", @auth_token, signature.to_json
end

private
def get_unix_date(value)
  (Date.today + value).to_time.to_i
end



