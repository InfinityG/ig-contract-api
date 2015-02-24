Feature: Contract creation
  Should be able to create a new contract on the API

  Scenario: Create new contract with 4 participants (oracle, initiator, sender, receiver), 1 ecdsa signature and 1 condition.
  Condition trigger has a single webhook and no transactions.
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
    And I have 1 conditions
    And condition 1 has the following signatures:
      | type  | participant_id | delegated_by |
      | ecdsa | 2              |              |
    And condition 1 has an expiry of 3 days from now
    And condition 1 has the following webhooks:
      | uri                |
      | www.mywebhook1.com |
      | www.mywebhook2.com |
    And I have a valid auth token on the API
    And I POST the contract to the API
    Then the API should respond with a 200 response code

  Scenario: Create new contract with 3 participants (initiator and sender are the same participant).
  Condition has a single transaction with an ecdsa signature.
    Given I have the following participants:
      | external_id | role_types    |
      | 1           | initiator,sender |
      | 2           | oracle        |
      | 3           | receiver         |
    And I have the following wallets:
      | participant_id | secret_threshold |
      | 1              | 1                |
      | 3              | 0                |
    And I have contract signatures from the following participants:
      | participant_id |
      | 2           |
    And the contract expiry date is 2 days from now
    And I have 1 conditions
    And condition 1 has the following signatures:
      | type  | participant_id | delegated_by |
      | ecdsa | 2              |              |
    And condition 1 has an expiry of 3 days from now
    And condition 1 has the following transactions:
      | from_participant | to_participant | amount | currency |
      | 1                | 3              | 100    | PDC      |
    And I have a valid auth token on the API
    And I POST the contract to the API
    Then the API should respond with a 200 response code

  Scenario: Create new contract with 3 participants (initiator and sender are the same participant).
  Condition has a single transaction with ss_key signature.
    Given I have the following participants:
      | external_id | role_types    |
      | 1           | initiator,sender |
      | 2           | oracle        |
      | 3           | receiver         |
    And I have the following wallets:
      | participant_id | secret_threshold |
      | 1              | 2                |
      | 3              | 0                |
    And I have contract signatures from the following participants:
      | participant_id |
      | 2           |
    And the contract expiry date is 2 days from now
    And I have 1 conditions
    And condition 1 has the following signatures:
      | type   | participant_id | delegated_by |
      | ss_key | 2              | 1            |
    And condition 1 has an expiry of 3 days from now
    And condition 1 has the following transactions:
      | from_participant | to_participant | amount | currency |
      | 1                | 3              | 100    | PDC      |
    And I have a valid auth token on the API
    And I POST the contract to the API
    Then the API should respond with a 200 response code

