require_relative '../../../tests/helpers/random_strings'
require_relative '../../../tests/config'
require_relative '../../../api/utils/rest_util'
require_relative '../../../api/constants/error_constants'
require_relative '../../../tests/features/step_definitions/step_helper'

require 'json'
require 'minitest'

Before do
  register_user
  set_trusted_domain
end

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
  @condition_sig_mode_hash = {}
  @condition_sig_threshold_hash = {}
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

And(/^condition (\d+) signature mode is ([^"]*)/) do |arg1, arg2|
  @condition_sig_mode_hash[arg1.to_i] = arg2
end

And(/^condition (\d+) signature threshold is (\d+)$/) do |arg1, arg2|
  @condition_sig_threshold_hash[arg1.to_i] = arg2
end

And(/^condition (\d+) has an expiry of (\d+) days from now$/) do |arg1, arg2|
  unix_date = get_unix_date arg2.to_i
  @condition_expiry_hash[arg1.to_i] = unix_date
end

And(/^condition (\d+) has the following webhooks:$/) do |arg, table|
  table.hashes.each do |item|
    @condition_webhooks_hash[arg.to_i] << @step_helper.create_webhook(item[:uri],
                                                                      item[:method],
                                                                      item[:headers],
                                                                      item[:body])
  end

  @condition_webhooks_hash
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
  authenticate_on_id_io

  # auth = @step_helper.create_canned_auth_payload

  rest_client = RestUtil.new
  result = rest_client.execute_post "#{CONTRACT_API_URI}/tokens", '', @id_io_auth
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
                                                    i, @condition_signatures_hash[i], @condition_sig_mode_hash[i],
                                                    @condition_sig_threshold_hash[i], @condition_expiry_hash[i])
  end

  contract = @step_helper.create_contract('Test contract 1', 'Test contract 1 description', @contract_expires,
                                          participants_arr, conditions_arr, @contract_signatures_arr)

  rest_client = RestUtil.new
  @result = rest_client.execute_post "#{CONTRACT_API_URI}/contracts", @auth_token, contract.to_json

end

Then(/^the API should respond with a (\d+) response code$/) do |arg|
  assert @result.response_code.to_s == arg
end

Given(/^I have an existing contract with condition signature modes ([^"]*)/) do |arg|
  steps "
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
    And I have 2 conditions
    And condition 1 signature mode is #{arg}"

  if arg == 'dynamic'
    steps '
    And condition 1 signature threshold is 1'
    end

  if arg == 'static'
    steps '
    And condition 1 has the following signatures:
      | type  | participant_id | delegated_by |
      | ecdsa | 2              |              |'
  end

  steps "
    And condition 1 has an expiry of 3 days from now
    And condition 1 has the following webhooks:
      | uri                         | headers  | method  | body             |
      | http://requestb.in/1a8hd8s1 |          | POST    | {'key1':'value'} |
    And condition 2 signature mode is #{arg}"

  if arg == 'dynamic'
    steps '
    And condition 2 signature threshold is 1'
  end

  if arg == 'static'
    steps '
    And condition 2 has the following signatures:
      | type  | participant_id | delegated_by |
      | ecdsa | 2              |              |'
  end

  steps '
    And condition 2 has an expiry of 3 days from now
    And condition 2 has the following webhooks:
      | uri                         | headers  | method  | body             |
      | http://requestb.in/1a8hd8s1 |          | POST    | {"key1":"value"} |
    And I have a valid auth token on the API
    And I POST the contract to the API
  '
end

When(/^I sign the contract$/) do
  @result = sign_contract
end

And(/^The contract state is ([^"]*)/) do |arg|
  if arg.to_s == 'active'
    sign_contract
  end
end

# This method is used for conditions with sig_mode='static'
When(/^I update a signature on the condition$/) do

  contract = JSON.parse(@result.response_body, :symbolize_names => true)
  @contract_id = contract[:id]
  condition = contract[:conditions][0]
  condition_id = condition[:id]
  condition_signature = condition[:signatures][0]
  @signature_id = condition_signature[:id]

  signer = contract[:participants].detect do |participant|
    participant[:id] == condition_signature[:participant_id]
  end

  signer_id = signer[:external_id].to_s

  # get the secret key for signing
  secret_key = @all_keys_hash[signer_id][:sk]

  # create the signature payload - the data to create a digest from and sign is the path to the signature
  signature_uri_fragment = "/contracts/#{@contract_id}/conditions/#{condition_id}/signatures/#{@signature_id}"
  @signature = @step_helper.create_updated_condition_signature signature_uri_fragment, secret_key

  # execute the request: /contracts/{id}/conditions/{id}/signatures/{id}
  rest_client = RestUtil.new
  @signature_uri = "#{CONTRACT_API_URI}#{signature_uri_fragment}"
  @result = rest_client.execute_post @signature_uri, @auth_token, @signature.to_json

  end

When(/^I update all signatures on the condition$/) do

  contract = JSON.parse(@result.response_body, :symbolize_names => true)
  @contract_id = contract[:id]
  condition = contract[:conditions][0]
  condition_id = condition[:id]

  condition[:signatures].each do |sig|

    signature_id = sig[:id]

    signer = contract[:participants].detect do |participant|
      participant[:id] == sig[:participant_id]
    end

    signer_id = signer[:external_id].to_s

    # get the secret key for signing
    secret_key = @all_keys_hash[signer_id][:sk]

    # create the signature payload - the data to create a digest from and sign is the path to the signature
    signature_uri_fragment = "/contracts/#{@contract_id}/conditions/#{condition_id}/signatures/#{signature_id}"
    signature = @step_helper.create_updated_condition_signature signature_uri_fragment, secret_key

    # execute the request: /contracts/{id}/conditions/{id}/signatures/{id}
    rest_client = RestUtil.new
    signature_uri = "#{CONTRACT_API_URI}#{signature_uri_fragment}"
    rest_client.execute_post signature_uri, @auth_token, signature.to_json
  end

end

When(/^I create a signature on the condition$/) do
  contract = JSON.parse(@result.response_body, :symbolize_names => true)
  @contract_id = contract[:id]
  condition = contract[:conditions][0]
  condition_id = condition[:id]

  # find the oracle for signing
  signer = contract[:participants].detect do |participant|
    participant[:roles].detect do |role|
      role == 'oracle'
    end
  end

  signer_id = signer[:external_id].to_s

  # get the secret key for signing
  secret_key = @all_keys_hash[signer_id][:sk]

  # create the signature payload - the data to create a digest from and sign is the path
  signature_uri_fragment = "/contracts/#{@contract_id}/conditions/#{condition_id}/signatures"

  # create the actual signature
  condition_signature = @step_helper.create_condition_signature signer_id, 'ecdsa', nil, signature_uri_fragment, secret_key

  # execute the request: /contracts/{id}/conditions/{id}/signatures
  rest_client = RestUtil.new
  @signature_uri = "#{CONTRACT_API_URI}#{signature_uri_fragment}"
  @result = rest_client.execute_post @signature_uri, @auth_token, condition_signature.to_json
end

And(/^I attempt to re-sign a condition$/) do
  rest_client = RestUtil.new
  @result = rest_client.execute_post @signature_uri, @auth_token, @signature.to_json

end

And(/^I retrieve a list of ([^"]*) contracts$/) do |arg|
  rest_client = RestUtil.new

  if arg.to_s == 'basic'
    @result = rest_client.execute_get "#{CONTRACT_API_URI}/contracts", @auth_token
  else
    @result = rest_client.execute_get "#{CONTRACT_API_URI}/contracts?full=true", @auth_token
  end

end

And(/^the response should contain ([^"]*) error$/) do |arg|

  case arg.to_s.downcase
    when 'contract not active'
      expected_err = (ErrorConstants::ContractErrors::INACTIVE_CONTRACT % @contract_id)
    when 'signature already recorded'
      expected_err = (ErrorConstants::ContractErrors::SIGNATURE_ALREADY_RECORDED % @signature_id)
    else
      raise 'Expected error not known'
  end

  response_body = JSON.parse(@result.response_body, :symbolize_names => true)
  assert response_body[:errors].detect do |error|
    error == expected_err
  end

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
  result = rest_client.execute_post "#{CONTRACT_API_URI}/contracts/#{contract_id}/signatures/#{signature_id}",
                                    @auth_token, signature.to_json
end

def register_user
  @first_name = 'Johnny'
  @last_name = RandomStrings.generate_alpha 15
  @username = 'johnny_' + @last_name + '@test.com'
  @password = 'passWOrd1!'
  @encoded_public_key = 'Ag7PunGy2BmnAi+PGE4/Dm9nCg1URv8wLZwSOggyfmAn' # already base64 encoded
  @encoded_secret_key = 'gCrHtl8VVWs6EuJLy7vPqVdBZWzRAR9ZCjIRRpoWvME=' # already base64 encoded
  @email = @email = "#{@first_name}_#{@last_name}@test.com"
  @mobile_number = '+21234567890'
  @meta = 'iwut748324'

  payload = {
      :first_name => @first_name,
      :last_name => @last_name,
      :username => @username,
      :password => @password,
      :public_key => @encoded_public_key,
      :email => @email,
      :mobile_number => @mobile_number,
      :meta => @meta
  }.to_json

  puts "Create user payload: #{payload}"

  result = RestUtil.new.execute_post(IDENTITY_API_URI + '/users', nil, payload)
  puts "Create user result: #{result.response_body}"

  @user_id = JSON.parse(result.response_body, :symbolize_names => true)
end

def set_trusted_domain
  @trusted_domain = 'accord.ly'
  @encoded_domain_aes_key = 'ky4xgi0+KvLYmVp1J5akqkJkv8z5rJsHTo9FcBc0hgo='

  payload = {
      :domain => @trusted_domain,
      :aes_key => @encoded_domain_aes_key,
      :login_uri => "https://#{@trusted_domain}/login"
  }.to_json

  puts "Create trusted domain payload: #{payload}"

  result = RestUtil.new.execute_post(IDENTITY_API_URI + '/trusts', IDENTITY_API_AUTH_KEY, payload)
  puts "Create trusted domain result: #{result.response_body}"

  assert result.response_code == 200
end

def authenticate_on_id_io
  payload = {
      :username => @username,
      :password => @password,
      :domain => @trusted_domain
  }.to_json

  puts "Login payload: #{payload}"

  result = RestUtil.new.execute_post(IDENTITY_API_URI + '/login', nil, payload)
  puts "Login result: #{result.response_body}"

  @id_io_auth = result.response_body
end

def get_unix_date(value)
  (Date.today + value).to_time.to_i
end


Then(/^the condition status should be complete$/) do
  pending
end