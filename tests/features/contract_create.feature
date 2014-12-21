Feature: Contract creation
  Should be able to create a new contract on the API

  Scenario: Create new contract with 4 participants (oracle, creator, payer, payee), 1 ecdsa signature and 1 condition.
  Condition trigger has a single webhook and no transactions.
    Given I have the following participants:
      | external_id | role_types | has_wallet |
      | 1           | creator    | false      |
      | 2           | oracle     | false      |
      | 3           | payer      | false      |
      | 4           | payee      | false      |
    And I have contract signatures from the following participants:
      | external_id |
      | 2           |
    And the contract expiry date is 1449878400
    And I have 1 conditions
    And condition 1 has the following signatures:
      | type  | participant_id |
      | ecdsa | 2              |
    And condition 1 has an expiry of 1449878400
    And condition 1 has the following webhooks:
      | uri                |
      | www.mywebhook1.com |
      | www.mywebhook2.com |
    And I POST the contract to the API
    Then the API should respond with a 200 response code

  Scenario: Create new contract with 3 participants (creator and payer are the same participant).
  Condition trigger has a single transaction and no webhooks.
    Given I have the following participants:
      | external_id | role_types    | has_wallet |
      | 1           | creator,payer | true       |
      | 2           | oracle        | false      |
      | 3           | payee         | true       |
    And I have contract signatures from the following participants:
      | external_id |
      | 2           |
    And the contract expiry date is 1449878400
    And I have 1 conditions
    And condition 1 has the following signatures:
      | type  | participant_id |
      | ecdsa | 2              |
    And condition 1 has an expiry of 1449878400
    And condition 1 has the following transactions:
      | from_participant | to_participant | amount | currency |
      | 1                | 3              | 100    | PDC      |
    And I POST the contract to the API
    Then the API should respond with a 200 response code


#  Scenario: Create new contract with 3 participants (creator and payer are the same participant).
#  Condition trigger has a single transaction.
#    Given I have the following participants:
#      | external_id | role_types    | has_wallet |
#      | 1           | creator,payer | true       |
#      | 2           | oracle        | false      |
#      | 4           | payee         | true      |
#    And I have contract signatures from the following participants:
#      | external_id |
#      | 2           |
#    And the contract expiry date is 1449878400
#    And I require the following conditions:
#      | signatures | expiry     | trigger_webhooks | trigger_transactions |
#      | 2,ecdsa    | 1449878400 |                  | 1,4,100,PDC                  |
#    And I POST the contract to the API
#    Then the API should respond with a 200 response code


#  Scenario: Create new contract with no signature
#    Given I have the following participants:
#      |role_type|
#      |creator|
#      |oracle|
#      |payer|
#      |payee|
#    And I have no contract signature
#    And the contract expiry date is 1449878400
#    And I require a single condition with an ecdsa signature from the "oracle" participant
#    And the condition expiry date is 1449878400
#    And the condition has a single webhook
#    When I POST the contract to the API
#    Then the API should respond with a 400 response code
#
#  Scenario: Create new contract with no participants
#    Given I have no participants
#    And I have no contract signature
#    And the contract expiry date is 1449878400
#    And I require a single condition with an ecdsa signature from the "oracle" participant
#    And the condition expiry date is 1449878400
#    And the condition has a single webhook
#    When I POST the contract to the API
#    Then the API should respond with a 400 response code