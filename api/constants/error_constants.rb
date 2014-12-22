module ErrorConstants

  module ContractErrors
    NO_CONTRACT_FOUND = 'No contract found with id %s'
    INACTIVE_CONTRACT = 'Contract % s is not active! You cannot sign a condition until all contract signatures are present.'
    NO_CONDITION_FOUND = 'No condition found with id %s'
    NO_SIGNATURE_FOUND = 'No signature found with id %s'
    NO_PARTICIPANT_FOUND = 'No participant found to validate signature!'
    UNKNOWN_SIGNATURE_TYPE = 'Unknown signature type!'
  end

  module ValidationErrors
    INVALID_CONTRACT_NAME = 'Invalid contract name'
    INVALID_CONTRACT_DESCRIPTION = 'Invalid contract description'
    INVALID_CONTRACT_EXPIRY = 'Invalid contract UNIX expiry date'

    INVALID_CONDITION_NAME = 'Invalid condition name'
    INVALID_CONDITION_DESCRIPTION = 'Invalid condition description'
    INVALID_CONDITION_SEQUENCE = 'Invalid condition sequence number'
    INVALID_CONDITION_EXPIRY = 'Invalid condition UNIX expiry date'

    INVALID_SIGNATURE_VALUE = 'Invalid signature value'
    INVALID_DIGEST_VALUE = 'Invalid digest value'

    INVALID_PARTICIPANT_CONTRACT_SIGNATURE = 'Invalid participant_external_id for contract signature'

    INVALID_PARTICIPANT_CONDITION_SIGNATURE = 'Invalid participant_external_id for condition signature'
    INVALID_SIGNATURE_TYPE_CONDITION = 'Invalid signature type for condition'

    SIGNATURE_REQUIRED = 'At least 1 signature is required!'

    INVALID_PARTICIPANT_EXTERNAL_ID = 'Invalid participant external_id'
    INVALID_PARTICIPANT_PUBLIC_KEY = 'Invalid participant public key'
    INVALID_PARTICIPANT_ROLE = 'Invalid participant role'

    NO_TRIGGER_FOUND = 'No trigger found!'

    TRANSACTION_OR_WEBHOOK_IN_TRIGGER = 'At least one transaction or webhook must be present in the trigger!'


    INVALID_TRANSACTION_FROM_PARTICIPANT = 'Invalid transaction from_participant_external_id'
    INVALID_TRANSACTION_TO_PARTICIPANT = 'Invalid transaction to_participant_external_id'
    INVALID_TRANSACTION_AMOUNT = 'Invalid transaction amount'
    INVALID_TRANSACTION_CURRENCY = 'Invalid transaction currency'

    INVALID_WEBHOOK = 'Invalid webhook for trigger'
  end
end