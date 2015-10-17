Feature: Condition signing
  Should be able to sign a contract condition on the API

  Scenario: Sign a condition on an active contract
    Given I have an existing contract
    And The contract state is "active"
    When I sign a condition
    Then the API should respond with a 200 response code

  Scenario: Re-sign a condition on an active contract
    Given I have an existing contract
    And The contract state is "active"
    When I sign a condition
    And I attempt to re-sign a condition
    Then the API should respond with a 400 response code

  Scenario: Sign a condition on an inactive contract
    Given I have an existing contract
    And The contract state is "pending"
    When I sign a condition
    Then the API should respond with a 400 response code