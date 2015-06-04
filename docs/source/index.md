---
title: API Reference

language_tabs:
  - shell
  - ruby
  - python

toc_footers:


includes:
  - errors

search: true
---

# Introduction

Welcome to the Smart Contract API, a RESTful API used to manage the creation and maintenance of digital contracts. It attempts to be as generic as possible to cater for very different use-cases.

**_Contract definition: "...an agreement with specific terms between two or more persons or entities in which there is a promise to do something in return for a valuable benefit ..."_**

This document is intended for use primarily by developers, and as such, assumes basic knowledge of HTTP, RESTful API's and JSON data structures.

You can view code examples in the dark area to the right, and you can switch the programming language of the examples with the tabs in the top right.

# Concepts

## Participants

Every contract requires a set of participants. Each participant performs a specific role, ie:

* **Initiator** - the creator of the contract
* **Oracle** - a human or machine responsible for approving that conditions have been met
* **Sender** - the person sending value to the receiver. This may have monetary value (in the case of a transaction) or simply a transfer of information (in the case of a webhook)
* **Receiver** - the person receiving value from the sender

## Signatures

Once a contract has been created, one or more participants (which may or may not include the oracle) is required to sign the contract as a whole. Each signature is attached to the contract.

A contract is marked as _"pending"_ until all signatures have been received. Once all signatures are present, the contract is then marked as _"active"_.

An _"active"_ contract is effectively locked and cannot be changed (except for condition signatures as they are completed - see below).

## Conditions

Each contract has one or more conditions attached. A condition is a step that must be performed by a participant (generally, but not restricted to, the "receiver" - see participants above).
Each condition must be fulfilled and approved before a contract is marked as complete.

### Condition Signatures

A signature is used to sign the condition, to indicate that the it has been met (generally this would be an oracle). A signatory would use a secret key to sign the condition, and the public key (contained in the participant) could be used to validate the signature before the signature is accepted and written into the contract record.

### Trigger

Each condition contains a trigger object, which itself may contain an array of **transactions** or **webhooks**. Transactions and/or webhooks are initiated when a condition has been met.

**_Transaction_**

Each transaction contains a "from" and "to" component, referring to the "sender" and "receiver" participants. It also contains an amount and currency details. Listed transactions will by default be initiated on the Contract API's payment gateway.

**_Webhook_**

In contrast to a transaction, a webhook is an endpoint that the Contract API will call when a condition is met. This means that if a different payment gateway is to be used, or the condition does not require a "traditional" value transfer (eg: a gift of a bottle of wine) then an external service can be set up to handle this via the webhook (eg: IronMQ, or IFTTT).
Request payloads to webhooks are POST by default, and may contain user-specified data. Webhook endpoints MUST be TLS enabled (HTTPS).


# Objects

A contract is a JSON document, which can be broken down into related entities as listed below.

## Contract object

The "top level" object which contains all other objects.

```
{
    "id": "",
    "name": "",
    "description": "",
    "expires": 0,
    "conditions": [],
    "participants":[],
    "signatures":[]
}
```

| Name         | Type    | Description                                    |
|--------------|---------|------------------------------------------------|
| id           | string  | A unique identifier generated by the API       |
| name         | string  | The name of the contract                       |
| description  | string  | The description of the contract                |
| expires      | integer | The expiry date of the contract in UNIX format |
| conditions   | array   | An array of [condition](#condition-object) objects                  |
| participants | array   | An array of [participant](#participant-object) objects                |
| signatures   | array   | An array of [signature](#signature-object) objects                  |

## Condition object

An object that defines a requirement that must be fulfilled.

```
{
    "id": "",
    "name": "",
    "description": "",
    "expires": "",
    "sequence_number": 0,
    "status":"",
    "trigger":{}
}
```

| Name            | Type    | Description                                                                 |
|-----------------|---------|-----------------------------------------------------------------------------|
| id              | string  | A unique identifier generated by the API                                    |
| name            | string  | The name of the condition                                                   |
| description     | string  | The description of the condition                                            |
| expires         | integer | The expiry date of the condition in UNIX format                             |
| sequence_number | integer | A number representing the order in which conditions are processed           |
| status          | string  | A string (_pending_ or _complete_) representing the status of the condition |
| trigger         | hash    | A hash representing a [trigger](#trigger-object) object

## Participant object

```
{
    "id": "",
    "external_id": "",
    "public_key": "",
    "roles": [],
    "wallet": {}
}
```

| Name        | Type   | Description                                                            |
|-------------|--------|------------------------------------------------------------------------|
| id          | string | A unique identifier generated by the API                               |
| external_id | string | The external id of a participant                                       |
| public_key  | string | The public key of the participant used for signing                     |
| roles       | array  | A (string) array of one or more roles (can be `initiator, oracle, sender, receiver`) |
| wallet      | hash   | A [wallet](#wallet-object) object                                                        |

## Signature object

Signatures can be found at both the contract and condition level.

* **Contract:** signatures indicate approval of the contract as a whole
* **Condition:** signatures indicate that a condition has been met

```
{
    "id": "",
    "participant_external_id": "",
    "participant_id": "",
    "delegated_by_external_id": "",
    "delegated_by_id": "",
    "type":"",
    "value":"",
    "digest":""
}
```

| Name                     | Type   | Description (contract)                            | Description (condition)                   |
|--------------------------|--------|------------------------------------------------|---------------------------------------------|
| id                       | string | A unique identifier generated by the API       | A unique identifier generated by the API                                                                                                                              |
| participant_external_id  | string | The external id of a [participant](#participant-object) | The external id of a [participant](#participant-object)                                                                                                                              |
| participant_id           | string | The id of the [participant](#participant-object) generated by the API |  The id of the [participant](#participant-object) generated by the API                                                                                                                             |
| delegated_by_external_id | string | (not used by contract signatures)              | The external id of a [participant](#participant-object) delegated to sign a condition if `type = ss_key`                                             |
| delegated_by_id          | string | (not used by contract signatures)              | The id of the delegated [participant](#participant-object) generated by the API                                                                      |
| type                     | string | (defaults to ecdsa)                            | `ecdsa` (when signing with a public key) OR `ss_key` (when signing with a shared secret fragment)                 |
| value                    | string | The private-key signed digest of the contract   | If `type = ecdsa`, this is the private-key signed digest of the [condition](#condition-object). If `type = ss_key`, this is a shared secret fragment |
| digest                   | string | SHA256 digest of the contract                  | SHA256 digest of the condition                                                                                                |

## Trigger object

A trigger is an object that is processed once a condition has been met (ie: all signatures for the condition have been received).

A trigger can contain one or more **transactions** and/or one or more **webhooks**, each of which is processed once the trigger is initiated.
(note: transactions and webhooks are optional; however at least one of either must be present for a trigger to be valid).

A trigger is processed **asynchronously**, ie: once a condition has been met, the trigger is placed on a queue which is handled on a separate
thread.

```
{
    "id": "",
    "transactions": [],
    "webhooks": []
}
```

| Name         | Type   | Description                                                                          |
|--------------|--------|--------------------------------------------------------------------------------------|
| id           | string | A unique identifier generated by the API                                             |
| transactions | array  | An array of [transaction](#transaction-object) objects that will be processed when the trigger is processed |
| webhooks     | string | An array of [webhook](#webhook-object) objects that will be processed when the trigger is processed     |

## Wallet object

A wallet is a container for a participant's cryptocurrency wallet details. Currently this only supports **Ripple** wallets, but in future will
support a number of different cryptocurrencies including **Bitcoin**.

```
{
    "id": "",
    "address": "",
    "destination_tag": "",
    "secret": {}
}
```

| Name            | Type   | Description                                                      |
|-----------------|--------|------------------------------------------------------------------|
| id              | string | A unique identifier generated by the API                         |
| address         | string | The (Ripple) address of the wallet                               |
| destination_tag | string | The destination tag of the wallet (when using managed wallets)   |
| secret          | hash   | The [secret](#secret-object) object representing the secret key (or key fragments) |

## Secret object

A secret represents the secret key of a cryptocurrency wallet. The _threshold_ value indicates how many fragments are required to
recreate a secret key using **[Shamir's Secret Sharing Algorithm](http://en.wikipedia.org/wiki/Shamir's_Secret_Sharing) (SSSA)**.

If the threshold is set to **1** then the secret key **has not** been split using SSSA. The _fragments_ array will then only contain 1 item,
which is the original secret key.

If the threshold is **>1**, then the original key **has** been split using SSSA. Collection of the fragments is done via the
condition signing process, when the specific signature type is **_ss_key_**. This means that a condition can be set to receive
a number of separate **_ss_key_** signatures, each of which adds an ss_key fragment to the _fragments_ array of the secret. Once
the threshold has been reached then the original secret can be re-created for use in a transaction.


```
{
    "id": "",
    "threshold": 0,
    "fragments": []
}
```

| Name      | Type    | Description                                                                                        |
|-----------|---------|----------------------------------------------------------------------------------------------------|
| id        | string  | A unique identifier generated by the API                                                           |
| threshold | integer | The minimum number of fragments required to generate the secret key                                |
| fragments | array   | An array of secret fragments. If `threshold = 1` then this will simply be the unfragmented secret. |

## Transaction object

The transaction object contains the details of a specific transfer of value from one participant to another. The _from_participant_
represents the **_sender_** and the _to_participant_ represents the **_receiver_**.

Transactions are only initiated once a trigger has been processed.

```
{
    "id": "",
    "from_participant_external_id": "",
    "from_participant": "",
    "to_participant_external_id": "",
    "to_participant": "",
    "amount":0,
    "currency":"",
    "status":"",
    "ledger_transaction_hash":""
}
```

| Name                         | Type    | Description                                                                                                  |
|------------------------------|---------|--------------------------------------------------------------------------------------------------------------|
| id                           | string  | A unique identifier generated by the API                                                                     |
| from_participant_external_id | string  | The external id of the [participant](#participant-object) from which funds will be sent                                             |
| from_participant             | string  | A unique identifer of the external id of the [participant](#participant-object) from which funds will be sent, generated by the API |
| to_participant_external_id   | string  | The external id of the [participant](#participant-object) to which funds will be sent                                               |
| to_participant               | string  | A unique identifer of the external id of the [participant](#participant-object) to which funds will be sent, generated by the API   |
| amount                       | integer | The amount to be sent                                                                                        |
| currency                     | string  | The currency (eg: AMP)                                                                                       |
| status                       | string  | A status flag indicating whether the transaction has been processed (`pending` or `complete`)                |
| ledger_transaction_hash      | string  |                                                                                                              |

## Webhook object

A webhook simply represents an HTTP endpoint. When a webhook is processed, the API will execute a **POST** request via **HTTPS**
to the specified uri. The payload of the request will be details of the condition in which the webhook resides.

```
{
    "id": "",
    "uri": "",
    "headers":[],
    "body":""
}
```

| Name      | Type   | Description                                                  |
|------     |--------|--------------------------------------------------------------|
| id        | string | A unique identifier generated by the API                     |
| uri       | string | The uri against which a POST request will be made by the API |
| headers   | array  | An array of header hashes (key:value pairs)                  |
| body      | string | The payload to be sent to the webhook uri                    |


## Putting it all together

```
{
    "id": "",
    "name": "",
    "description": "",
    "expires": "",
    "conditions": [
        {
            "id": "",
            "name": "",
            "description": "",
            "sequence_number": "",
            "signatures": [
                {
                    "id": "",
                    "participant_external_id": "",
                    "delegated_by_external_id": "",
                    "value": "",
                    "digest": ""
                }
            ],
            "status": "",
            "trigger": {
                "id": "",
                "transactions": [
                    {
                        "id": "",
                        "from_participant_external_id": "",
                        "to_participant_external_id": "",
                        "amount": "",
                        "currency": "",
                        "status": "",
                        "ledger_transaction_hash": ""
                    }
                ],
                "webhooks": [
                    {
                        "id": "",
                        "uri": ""
                    }
                ]
            },
            "expires": ""
        }
    ],
    "participants": [
        {
            "id": "",
            "external_id": "",
            "role": "",
            "public_key": "",
            "wallet": {
                "address": "",
                "destination_tag": "",
                "secret": {
                    "fragments": [],
                    "threshold": ""
                }
            }
        }
    ],
    "signatures": [
        {
            "id": "",
            "participant_external_id": "",
            "value": "",
            "digest": ""
        }
    ]
}
```

The JSON representation to the right shows the relationships between the objects discussed above.


# Requests

## Authentication

> To authorize, use this code:

```shell
# With shell, you can just pass the correct header with each request
curl "api_endpoint_here"
  -H "Authorization:[key]"
```

> Make sure to replace `[key]` with your API key.

An API key is required to access the API. This key must be included in all requests to the server in a header that looks like the following:

`Authorization:[key]`

<aside class="notice">
You must replace `[key]` with your personal API key.
</aside>

<aside class="warning">A 403 response will be received if an Authorization header is not set!</aside>

## Create Contract

This endpoint creates a new contract.

### HTTP Request

`POST https://api.infinity-g.com/v1/contracts`

### JSON Payload

Field name      | Description                                                       | Required
----------      | -----------                                                       | --------
name            | The name of the contract                                          | Y
description     | The description of the contract                                   | Y
expires         | The UNIX expiry date of the contract                              | Y
participants    | An array of participants (see [participant](#participant-object)) | Y
signatures      | An array of signatures (see [signature](#participant-object))     | Y
conditions      | An array of conditions (see [condition](#condition-object))       | Y

<aside class="notice">
Creation of a new contract is a single-step operation. Once created, a contract cannot be updated (except for updating signature values).
This means that a consuming system must be clear in what it is trying to achieve when creating the contract structure.
</aside>

<aside class="success">
Remember the Authorization header!
</aside>

```ruby
```

```python
```

```shell
curl "https://api.infinity-g.com/v1/contracts"
  -H "Authorization:[key]"
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
                      "initiator",
                      "sender"
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
                      "receiver"
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
                "initiator",
                "sender"
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
                "receiver"
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

### Sample

The sample to the right demonstrates the following scenario:

**Participants**

* Participant 1:
    * Roles: `initiator` and `sender` (the creator of the contract will also send funds)
    * Wallet: contains public address and a single secret key (unfragmented)
* Participant 2:
    * Roles: `oracle`
    * Wallet: none
* Participant 3:
    * Roles: `receiver`
    * Wallet: public address to receive funds. _No_ secret key

**Contract signatures**

* One signature:
    * required from the `initiator`

**Conditions**

* One condition:
    * Signatures: single signature required (ECDSA)
    * Trigger:
        * Transactions: single transaction from `sender` participant to `receiver` participant

## Get Contract

This endpoint retrieves a specific contract.

```ruby
```

```python
```

```shell
curl "https://api.infinity-g.com/v1/contracts/54a040b6b85a5428ea000042"
  -H "Authorization: [key]"
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
                "initiator",
                "sender"
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
                "receiver"
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

### HTTP Request

`GET https://api.infinity-g.com/v1/contracts/{contract_id}`

### Uri parameters

Parameter  | Description
--------- | -----------
contract_id | The id of the contract to retrieve

<aside class="success">
Remember the Authorization header!
</aside>


## Update Contract Signature

This endpoint updates a specific signature of a contract.

```ruby
```

```python
```

```shell
curl "https://api.infinity-g.com/v1/contracts"
  -H "Authorization:[key]"
  -H "Accept: application/json"
  -X POST
  -d '{
    "value": "MEQCIFbMB8M56zrYbyJbCMO1FCw9JioY5aDSjkIwUP8kHEX6AiAC8nxHmkg+\nPsrQxpCbMmrchHb6R5Pzxh34yyyzCo4X6Q==\n",
    "digest": "5Ri3cW7nHZmFaqSMPtHHWwBi1GOgekhIEL9vQOXPvmw="
}'

```

### HTTP Request

`POST https://api.infinity-g.com/v1/contracts/{contract_id}/signatures/{signature_id}`

### Uri parameters

Parameter  | Description
--------- | -----------
contract_id | The id of the contract to sign
signature_id | The id of the signature to update

### JSON Payload

Field name      | Description                                       | Required
----------      | -----------                                       | --------
value           | The private-key signed digest of the contract     | Y
digest          | The SHA256 hash of the contract                   | Y

The API will use the participant associated with the signature_id to retrieve the relevant public key. This key is then used
to validate the signature.

<aside class="success">
Remember the Authorization header!
</aside>

## Get Condition

This endpoint retrieves a specific condition.

```ruby
```

```python
```

```shell
curl "https://api.infinity-g.com/v1/contracts/54a040b6b85a5428ea000042/conditions/54a040b6b85a5428ea000040"
  -H "Authorization:[key]"
```

> The above command returns JSON structured like this:

```json
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
```

### HTTP Request

`GET https://api.infinity-g.com/v1/contracts/{contract_id}/conditions/{condition_id}`

### Uri parameters

Parameter       | Description
---------       | -----------
contract_id     | The id of the contract to which the condition belongs
condition_id    | The id of the condition to retrieve

<aside class="success">
Remember the Authorization header!
</aside>

## Update Condition Signature

This endpoint updates a specific signature for a condition.

### HTTP Request

`POST https://api.infinity-g.com/v1/contracts/{contract_id}/conditions/{condition_id}/signatures/{signature_id}`

### Uri parameters

Parameter  | Description
--------- | -----------
contract_id | The id of the contract
condition_id | The id of the condition to sign
signature_id | The id of the signature to update

### JSON Payload

Field name      | Description                                                                   | Required
----------      | -----------                                                                   | --------------------------------------
value           | if `type`=`ecdsa`, this is the private-key signed digest of the condition     | Y if `type`=`ecdsa`
                | if `type`=`ss_key`, this is a secret key fragment                             | Y if `type`=`ss_key`
digest          | if `type`=`ecdsa`, this is the SHA256 hash of the contract                    | Y if `type`=`ecdsa`
                |                                                                               | N if `type`=`ss_key`


The API will use the participant associated with the signature_id to retrieve the relevant public key. This key is then used
to validate the signature.

<aside class="success">
Remember the Authorization header!
</aside>