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
    And the contract expiry date is 1449878400
    And I require a single condition with an ecdsa signature from the "oracle"
    And the condition expiry date is 1449878400
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
    And the contract expiry date is 1449878400
    And I require a single condition with an ecdsa signature from the "oracle"
    And the condition expiry date is 1449878400
    And the condition has a single webhook
    When I POST the contract to the API
    Then the API should respond with a 400 response code

  Scenario: Create new contract with no participants
    Given I have no participants
    And I have no contract signature
    And the contract expiry date is 1449878400
    And I require a single condition with an ecdsa signature from the "oracle"
    And the condition expiry date is 1449878400
    And the condition has a single webhook
    When I POST the contract to the API
    Then the API should respond with a 400 response code