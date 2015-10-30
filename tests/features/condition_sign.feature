Feature: Condition signing
  Should be able to sign a contract condition on the API

  Scenario: Sign an existing condition with signature mode STATIC on an active contract
    Given I have an existing contract with condition signature modes static
    And The contract state is active
    When I update a signature on the condition
    Then the API should respond with a 200 response code

  Scenario: Sign all signatures on an existing condition with signature mode STATIC on an active contract
    Given I have an existing contract with condition signature modes static
    And The contract state is active
    When I update all signatures on the condition
    Then the condition status should be complete

  Scenario: Sign an existing condition with signature mode DYNAMIC on an active contract
    Given I have an existing contract with condition signature modes dynamic
    And The contract state is active
    When I create a signature on the condition
    Then the API should respond with a 200 response code

  Scenario: Re-sign a condition on an active contract
    Given I have an existing contract with condition signature modes static
    And The contract state is active
    When I update a signature on the condition
    And I attempt to re-sign a condition
    Then the API should respond with a 400 response code
    And the response should contain signature already recorded error

  Scenario: Sign a condition with signature mode STATIC on an inactive contract
    Given I have an existing contract with condition signature modes static
    And The contract state is pending
    When I update a signature on the condition
    Then the API should respond with a 400 response code
    And the response should contain contract not active error