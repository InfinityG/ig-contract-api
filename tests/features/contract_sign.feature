Feature: Contract signing
  Should be able to sign a contract on the API

  Scenario: Sign a contract as an oracle
    Given I have an existing contract
    When I sign the contract
    Then the API should respond with a 200 response code