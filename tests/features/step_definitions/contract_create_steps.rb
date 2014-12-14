require_relative '../../../api/utils/hash_generator'
require_relative '../../../api/utils/rest_util'
require 'json'
require 'minitest'

Given(/^I have the following participants:$/) do |table|
  # table is a table.hashes.keys # => [:role_type]

  @participants_arr = []

  generator = HashGenerator.new
  generator.generate_uuid

  table.hashes.each do |role|
    @participants_arr << {:external_id => generator.generate_random_number, :role => role[:role_type], :public_key => 'wewere'}
  end
end

And(/^I have a single contract signature from the "([^"]*)"$/) do |arg|
  @contract_signatures_arr = []

  participant = @participants_arr.detect do |participant|
    participant[:role] == arg
  end
  @contract_signatures_arr << {:participant_external_id => participant[:external_id]}
end

And(/^I have no contract signature$/) do
  @contract_signatures_arr = nil
end

And(/^the contract is set to expire in (\d+) days$/) do |arg|
  @contract_expires = arg
end

And(/^I require a single condition with a signature from the "([^"]*)"$/) do |arg|

  @conditions_arr = []

  participant = @participants_arr.detect do |participant|
    participant[:role] == arg
  end

  @conditions_arr << {:name => 'Test condition 1',
                      :description => 'Test condition 1 description',
                      :sequence_number => 1,
                      :signatures => [
                          {:participant_external_id => participant[:external_id]}
                      ]}
end

And(/^the condition is set to expire in (\d+) day$/) do |arg|
  @conditions_arr[0][:expires] = arg
end

And(/^the condition has a single webhook$/) do
  @conditions_arr[0][:trigger] = {:webhooks => [{:uri => 'https://mytestwebhook.com'}]}
end

When(/^I POST the contract to the API$/) do

  contract = {:name => 'Test contract 1',
              :description => 'My test contract 1 description',
              :participants => @participants_arr,
              :conditions => @conditions_arr,
              :signatures => @contract_signatures_arr,
              :expires => @contract_expires}

  rest_client = RestUtil.new
  @result = rest_client.execute_post 'http://localhost:9000/contracts', contract.to_json

end

Then(/^the API should respond with a (\d+) response code$/) do |arg|
  assert @result.response_code.to_s == arg
end