---
title: API Reference

language_tabs:
  - shell
  - ruby
  - python

toc_footers:
  - <a href='#'>Sign Up for a Developer Key</a>
  - <a href='http://github.com/tripit/slate'>Documentation Powered by Slate</a>

includes:
  - errors

search: true
---

# Introduction

Welcome to the IG Contract API. You can view code examples in the dark area to the right, and you can switch the programming language of the examples with the tabs in the top right.

# Contract concepts

## Participants

Every contract requires a set of participants. Each participant performs a specific role, ie:

* Initiator
  * The creator of the contract
* Oracle
  * A human or machine responsible for approving that conditions have been met
* Payer
  * The person sending value to the payee
* Payee
  * The person receiving value from the payer

## Conditions

Each contract has one or more conditions attached. A condition is a step that must be performed by a participant (generally, but not restricted to, the "payee" - see participants above).
Each condition must be fulfilled and approved before a contract is marked as complete.

### Signatories

A signatory is a participant (see above) that is required to sign the condition, to indicate that the it has been met (generally this would be an oracle). A signatory would use a secret key to sign the condition, and the public key (contained in the participant) could be used to validate the signature before the signature is accepted and written into the contract record.

### Trigger

Each condition contains a trigger object, which itself may contain an array of transactions or webhooks. Transactions and/or webhooks are initiated when a condition has been met.

Each transaction contains a "from" and "to" component, referring to the "payer" and "payee" participants. It also contains an amount and currency details. Listed transactions will by default be initiated on the Contract API's payment gateway.

In contrast to a transaction, a webhook is an endpoint that the Contract API will call when a condition is met. This means that if a different payment gateway is to be used, or the condition does not require a "traditional" value transfer (eg: a gift of a bottle of wine) then an external service can be set up to handle this via the webhook (eg: IronMQ, or IFTTT).

Request payloads to webhooks are POST by default, and will contain the full contract in JSON format. Webhook endpoints MUST be TLS enabled (HTTPS).

### Signatures

When a contract is created, each of the participants (which may or may not include the oracle) is required to sign the contract as a whole. Each signature is attached to the contract. Once this has been done, then the contract is "locked" and cannot be changed (the only thing that is allowed to be updated on the contract is the status and signatures on each condition as they are completed).

# General structure

A contract is a JSON document. The general structure of the document is shown below. The details and descriptions of the fields can be found in the **"objects"** section.

`
{
    "id": "",
    "name": "",
    "description": "",
    "participants": [
        {
            "id": "",
            "external_id": "",
            "role": ""
            "public_signing_key": "",
            "wallet":{
                "address": "",
                "destination_tag": "",
                "secret":{
                    "fragments":[],
                    "min_fragments":""
                }
            },
        },
        ...
    ],
    "conditions": [
        {
            "id": "",
            "name": "",
            "description": "",
            "sequence_number": "",
            "signatures": [
                {
                    "id":"",
                    "signatory_participant_external_id": "",
                    "ss_key_participant_external_id": "",
                    "value": "",
                    "digest":""
                },
                ...
            ],
            "status": "",
            "trigger": {
                "id":"",
                "transactions": [
                    {
                        "id": "",
                        "from_participant_external_id": "",
                        "to_participant_external_id": "",
                        "amount": "",
                        "currency": "",
                        "status": "",
                        "ledger_transaction_hash": ""
                    },
                    ...
                ],
                "webhooks": [
                    {
                        "id":"",
                        "uri:""
                    },
                    ...
                ]
            },
            "expires": ""
        },
        ...
    ],
    "signatures": [
        {
            "id":"",
            "participant_external_id": "",
            "value": "",
            "digest":""
        },
        ...
    ],
    "expires": ""
}
`

# Objects

A contract is a JSON document, and as such, the "objects" that make up a contract are essentially JSON fields.

## The Contract object

| Name         | Type    | Description                                    |
|--------------|---------|------------------------------------------------|
| id           | string  | A unique identifier generated by the API       |
| name         | string  | The name of the contract                       |
| description  | string  | The description of the contract                |
| expires      | integer | The expiry date of the contract in UNIX format |
| conditions   | array   | An array of condition objects                  |
| participants | array   | An array of participant objects                |
| signatures   | array   | An array of signature objects                  |

## The Condition object

| Name            | Type    | Description                                                                 |
|-----------------|---------|-----------------------------------------------------------------------------|
| id              | string  | A unique identifier generated by the API                                    |
| name            | string  | The name of the condition                                                   |
| description     | string  | The description of the condition                                            |
| expires         | integer | The expiry date of the condition in UNIX format                             |
| sequence_number | integer | A number representing the order in which conditions are processed           |
| status          | string  | A string (_pending_ or _complete_) representing the status of the condition |
| trigger         | hash    | An array of signature objects                                               |

## The Trigger object

| Name         | Type   | Description                                                                          |
|--------------|--------|--------------------------------------------------------------------------------------|
| id           | string | A unique identifier generated by the API                                             |
| transactions | array  | An array of Transaction objects that will be processed when the Trigger is processed |
| webhooks     | string | An array of Webhook objects that will be processed when the Trigger is processed     |


## The Participant object

| Name        | Type   | Description                                                            |
|-------------|--------|------------------------------------------------------------------------|
| id          | string | A unique identifier generated by the API                               |
| external_id | string | The external id of a Participant                                       |
| public_key  | string | The public key of the Participant used for signing                     |
| roles       | array  | An array of one or more roles (can be `creator, oracle, payer, payee`) |
| wallet      | hash   | A Wallet object                                                        |

## The Wallet object

| Name            | Type   | Description                                                      |
|-----------------|--------|------------------------------------------------------------------|
| id              | string | A unique identifier generated by the API                         |
| address         | string | The (Ripple) address of the wallet                               |
| destination_tag | string | The destination tag of the wallet (when using managed wallets)   |
| secret          | hash   | The Secret object representing the secret key (or key fragments) |

## The Secret object

| Name      | Type    | Description                                                                                        |
|-----------|---------|----------------------------------------------------------------------------------------------------|
| id        | string  | A unique identifier generated by the API                                                           |
| threshold | integer | The minimum number of fragments required to generate the secret key                                |
| fragments | array   | An array of secret fragments. If `threshold = 1` then this will simply be the unfragmented secret. |

## The Signature object

| Name                     | Type   | Description (when used in Contract)            | Description (when used in Condition)                                                                                          |
|--------------------------|--------|------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------|
| id                       | string | A unique identifier generated by the API       |                                                                                                                               |
| participant_external_id  | string | The external id of a Participant               |                                                                                                                               |
| participant_id           | string | The id of the Participant generated by the API |                                                                                                                               |
| delegated_by_external_id | string | (not used by Contract signatures)              | The external id of a Participant delegated to sign a Condition if `type = ss_key`                                             |
| delegated_by_id          | string | (not used by Contract signatures)              | The id of the delegated Participant generated by the API                                                                      |
| type                     | string | (defaults to ecdsa)                            | `_ecdsa_` (when public key signing of a Condition) OR `_ss_key_` (when signing with a shared secret fragment)                 |
| value                    | string | The public-key signed digest of the Contract   | If `type = ecdsa`, this is the public-key signed digest of the Condition If `type = ss_key`, this is a shared secret fragment |
| digest                   | string | SHA256 digest of the Contract                  | SHA256 digest of the Condition                                                                                                |

## The Transaction object

| Name                         | Type    | Description                                                                                                  |
|------------------------------|---------|--------------------------------------------------------------------------------------------------------------|
| id                           | string  | A unique identifier generated by the API                                                                     |
| from_participant_external_id | string  | The external id of the Participant from which funds will be sent                                             |
| from_participant             | string  | A unique identifer of the external id of the Participant from which funds will be sent, generated by the API |
| to_participant_external_id   | string  | The external id of the Participant to which funds will be sent                                               |
| to_participant               | string  | A unique identifer of the external id of the Participant to which funds will be sent, generated by the API   |
| amount                       | integer | The amount to be sent                                                                                        |
| currency                     | string  | The currency (eg: AMP)                                                                                       |
| status                       | string  | A status flag indicating whether the transaction has been processed (`pending` or `complete`)                |
| ledger_transaction_hash      | string  |                                                                                                              |

## The Webhook object

| Name | Type   | Description                                                  |
|------|--------|--------------------------------------------------------------|
| id   | string | A unique identifier generated by the API                     |
| uri  | string | The uri against which a POST request will be made by the API |


# Requests

## Authentication

> To authorize, use this code:

```shell
# With shell, you can just pass the correct header with each request
curl "api_endpoint_here"
  -H "Authorization: [key]"
```

> Make sure to replace `[key]` with your API key.

API keys are required to access the API. API keys must be included in all API requests to the server in a header that looks like the following:

`Authorization: [key]`

<aside class="notice">
You must replace `[key]` with your personal API key.
</aside>

## Create new Contract



```ruby
```

```python
```

```shell
curl "http://localhost:9000/contracts"
  -H "Authorization: [key]"
  -H "Accept: application/json"
  -X POST
  -d '{
          "name": "Test contract 1",
          "description": "Test contract 1 description",
          "expires": 1419897600,
          "participants": [
              {
                  "external_id": "1",
                  "roles": [
                      "creator",
                      "payer"
                  ],
                  "public_key": "BKID9EgNllR9zNcwXDxdMbU76s0WwpMeD31vrTaxyDg3k53W/NFIo0G6ggO1\nzonI2zsgRbeQutIFfFqpHHPEY3Q=\n",
                  "wallet": {
                      "address": "2147d348-6a31-484c-b974-f4452f006e81",
                      "destination_tag": null,
                      "secret": {
                          "fragments": [
                              "TaWs+hB2uowc5ZOzZZ0er9S/rZ+yNgjOAMmhM0Mpkgg=\n"
                          ],
                          "threshold": 1
                      }
                  }
              },
              {
                  "external_id": "2",
                  "roles": [
                      "oracle"
                  ],
                  "public_key": "BI+vVlovs0j+wSxrUoZZf3GRjvy0bi9cXb8ksd4mR0WYPUAAwIbIAcPP++Qy\n++RoDJ0sgyaIjZPV10E9s2byd1s=\n",
                  "wallet": null
              },
              {
                  "external_id": "3",
                  "roles": [
                      "payee"
                  ],
                  "public_key": "BOnjAl6WzsGR6cfjR0DvB321hnveTErmXt/UpQUbeTrUdrJir13Agv/pRq2F\nt4kvtm7wh9kRZb3pNHe1dOQKmoE=\n",
                  "wallet": {
                      "address": "38c7cf68-dcb8-409d-b686-5ba212f0951e",
                      "destination_tag": null,
                      "secret": null
                  }
              }
          ],
          "signatures": [
              {
                  "participant_external_id": "2",
                  "type": null,
                  "delegated_by_external_id": null
              }
          ],
          "conditions": [
              {
                  "name": "Test condition 1",
                  "description": "Test condition 1 description",
                  "sequence_number": 1,
                  "signatures": [
                      {
                          "participant_external_id": "2",
                          "type": "ecdsa",
                          "delegated_by_external_id": ""
                      }
                  ],
                  "trigger": {
                      "transactions": [
                          {
                              "from_participant_external_id": "1",
                              "to_participant_external_id": "3",
                              "amount": "100",
                              "currency": "PDC"
                          }
                      ],
                      "webhooks": []
                  },
                  "expires": 1419984000
              }
          ]
      }'
```

> The above command returns JSON structured like this:

```json
{
    "conditions": [
        {
            "description": "Test condition 1 description",
            "expires": 1419984000,
            "id": "54a040b6b85a5428ea000040",
            "name": "Test condition 1",
            "sequence_number": 1,
            "signatures": [
                {
                    "delegated_by_id": "",
                    "id": "54a040b6b85a5428ea00003d",
                    "participant_id": "54a040b6b85a5428ea00003a",
                    "type": "ecdsa"
                }
            ],
            "status": "pending",
            "trigger": {
                "id": "54a040b6b85a5428ea00003f",
                "transactions": [
                    {
                        "amount": 100,
                        "currency": "PDC",
                        "from_participant_id": "54a040b6b85a5428ea000039",
                        "id": "54a040b6b85a5428ea00003e",
                        "status": "pending",
                        "to_participant_id": "54a040b6b85a5428ea00003c"
                    }
                ],
                "webhooks": []
            }
        }
    ],
    "description": "Test contract 1 description",
    "expires": 1419897600,
    "id": "54a040b6b85a5428ea000042",
    "name": "Test contract 1",
    "participants": [
        {
            "external_id": 1,
            "id": "54a040b6b85a5428ea000039",
            "public_key": "BKID9EgNllR9zNcwXDxdMbU76s0WwpMeD31vrTaxyDg3k53W/NFIo0G6ggO1\nzonI2zsgRbeQutIFfFqpHHPEY3Q=\n",
            "roles": [
                "creator",
                "payer"
            ],
            "wallet": {
                "address": "2147d348-6a31-484c-b974-f4452f006e81",
                "id": "54a040b6b85a5428ea000038",
                "secret": {
                    "fragments": [
                        "TaWs+hB2uowc5ZOzZZ0er9S/rZ+yNgjOAMmhM0Mpkgg=\n"
                    ],
                    "id": "54a040b6b85a5428ea000037",
                    "threshold": 1
                }
            }
        },
        {
            "external_id": 2,
            "id": "54a040b6b85a5428ea00003a",
            "public_key": "BI+vVlovs0j+wSxrUoZZf3GRjvy0bi9cXb8ksd4mR0WYPUAAwIbIAcPP++Qy\n++RoDJ0sgyaIjZPV10E9s2byd1s=\n",
            "roles": [
                "oracle"
            ],
            "wallet": null
        },
        {
            "external_id": 3,
            "id": "54a040b6b85a5428ea00003c",
            "public_key": "BOnjAl6WzsGR6cfjR0DvB321hnveTErmXt/UpQUbeTrUdrJir13Agv/pRq2F\nt4kvtm7wh9kRZb3pNHe1dOQKmoE=\n",
            "roles": [
                "payee"
            ],
            "wallet": {
                "address": "38c7cf68-dcb8-409d-b686-5ba212f0951e",
                "id": "54a040b6b85a5428ea00003b",
                "secret": null
            }
        }
    ],
    "signatures": [
        {
            "id": "54a040b6b85a5428ea000041",
            "participant_id": "54a040b6b85a5428ea00003a"
        }
    ],
    "status": "pending"
}
```

This endpoint retrieves all kittens.

### HTTP Request

`GET http://example.com/kittens`

### Query Parameters

Parameter | Default | Description
--------- | ------- | -----------
include_cats | false | If set to true, the result will also include cats.
available | true | If set to false, the result will include kittens that have already been adopted.

<aside class="success">
Remember — a happy kitten is an authenticated kitten!
</aside>

## Get a Specific Kitten

```ruby
require 'kittn'

api = Kittn::APIClient.authorize!('meowmeowmeow')
api.kittens.get(2)
```

```python
import kittn

api = kittn.authorize('meowmeowmeow')
api.kittens.get(2)
```

```shell
curl "http://example.com/api/kittens/3"
  -H "Authorization: meowmeowmeow"
```

> The above command returns JSON structured like this:

```json
{
  "id": 2,
  "name": "Isis",
  "breed": "unknown",
  "fluffiness": 5,
  "cuteness": 10
}
```

This endpoint retrieves a specific kitten.

<aside class="warning">If you're not using an administrator API key, note that some kittens will return 403 Forbidden if they are hidden for admins only.</aside>

### HTTP Request

`GET http://example.com/kittens/<ID>`

### URL Parameters

Parameter | Description
--------- | -----------
ID | The ID of the cat to retrieve

