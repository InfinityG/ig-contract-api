Feature: Contract creation
  Should be able to create a new contract on the API

  Scenario: Should be able to retrieve a contract list
    Given I have an existing contract
    And I retrieve a list of full contracts
    Then the API should respond with a 200 response code

  Scenario: Should be able to retrieve a contract list
    Given I have an existing contract
    And I retrieve a list of basic contracts
    Then the API should respond with a 200 response code
