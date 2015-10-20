Feature: Condition signing
  Should be able to sign a contract condition on the API

  Scenario: Sign an existing condition on an active contract
    Given I have an existing contract
    And The contract state is "active"
    When I sign the condition
    Then the API should respond with a 200 response code

  Scenario: Re-sign a condition on an active contract
    Given I have an existing contract
    And The contract state is "active"
    When I sign the condition
    And I attempt to re-sign a condition
    Then the API should respond with a 400 response code
    And the response should contain signature already recorded error

  Scenario: Sign a condition on an inactive contract
    Given I have an existing contract
    And The contract state is "pending"
    When I sign the condition
    Then the API should respond with a 400 response code
    And the response should contain contract not active error