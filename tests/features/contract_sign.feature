Feature: Contract signing
  Should be able to sign a contract on the API

  Scenario: Oracle signs an unsigned contract with ecdsa signature
    Given I am a signatory participant
    And I have a contract id
    And I have a signature id
    And the signature must be an ecdsa type
    And I create a digest of the entire contract
    And I sign the digest
    When I POST the signature to the API
    Then the API should respond with a 200 response code

