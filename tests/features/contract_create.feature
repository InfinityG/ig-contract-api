Feature: Contract creation
  Should be able to create a new contract on the API

  Scenario: Create new contract
    Given I have the following participants:
          |role_type|
          |creator|
          |oracle|
          |payer|
          |payee|
    And I have a single contract signature from the "creator"
    And the contract is set to expire in 7 days
    And I require a single condition with a signature from the "oracle"
    And the condition is set to expire in 1 day
    And the condition has a single webhook
    When I POST the contract to the API
    Then the API should respond with a 200 response code

  Scenario: Create new contract with no signature
    Given I have the following participants:
      |role_type|
      |creator|
      |oracle|
      |payer|
      |payee|
    And I have no contract signature
    And the contract is set to expire in 7 days
    And I require a single condition with a signature from the "oracle"
    And the condition is set to expire in 1 day
    And the condition has a single webhook
    When I POST the contract to the API
    Then the API should respond with a 400 response code