module ErrorConstants

  module ContractErrors
    NO_CONTRACT_FOUND = 'No contract found with id %s'
    INACTIVE_CONTRACT = 'Contract % s is not active! You cannot sign a condition until all contract signatures are present.'
    NO_CONDITION_FOUND = 'No condition found with id %s'
    NO_SIGNATURE_FOUND = 'No signature found with id %s'
    NO_PARTICIPANT_FOUND = 'No participant found to validate signature!'
    UNKNOWN_SIGNATURE_TYPE = 'Unknown signature type!'
    INVALID_SIGNATURE = 'Invalid signature!'
    SIGNATURE_ALREADY_RECORDED = 'Signature %s already recorded!'
    NO_ORACLE_ON_CONDITION = 'No oracle found on condition!'
    INVALID_DIGEST = 'Digest does not have the expected value'
    INVALID_WEBHOOK_METHOD = 'Invalid HTTP method on webhook'
  end

  module ValidationErrors
    NO_DATA_FOUND = 'No data found!'

    INVALID_EXTERNAL_USER_ID = 'Invalid external user id'
    INVALID_EMAIL = 'Invalid user email'
    INVALID_FIRST_NAME = 'Invalid user first name'
    INVALID_LAST_NAME = 'Invalid user last name'
    INVALID_USERNAME = 'Invalid username'

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
    INVALID_DELEGATED_PARTICIPANT = 'Invalid delegated participant_id for ss_key type signature'
    INVALID_SECRET_THRESHOLD = 'Secret threshold must be greater than 1 in delegated participant wallet'
    INVALID_SECRET_FRAGMENT_LENGTH = 'Secret fragment length must be greater than 1 in delegated participant wallet'

    SIGNATURE_REQUIRED = 'At least 1 signature is required!'
    INVALID_CONDITION_SIGNATURE_TYPE = 'Invalid signature type for condition'
    INVALID_CONDITION_SIGNATURE_MODE = "Invalid signature mode for condition. Must be 'static' or 'dynamic'"
    INVALID_CONDITION_SIGNATURE_COUNT = "Invalid number of signatures in the condition. Check that 'sig_mode' is set to the correct value."
    INVALID_CONDIITON_SIGNATURE_THRESHOLD = 'Invalid condition signature threshold'

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