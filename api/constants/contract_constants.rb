module GeneralConstants
  module ContractConstants
    ROLE_INITIATOR = 'initiator'
    ROLE_ORACLE = 'oracle'
    ROLE_SENDER = 'sender'
    ROLE_RECEIVER = 'receiver'
    ROLES = [ROLE_INITIATOR, ROLE_ORACLE, ROLE_SENDER, ROLE_RECEIVER]
    PUBLIC_KEY = 'ecdsa'
    SHARED_SECRET = 'ss_key'
    SIGNATURE_MODE_FIXED = 'fixed'
    SIGNATURE_MODE_VARIABLE = 'variable'
    SIGNATURE_MODES = [SIGNATURE_MODE_FIXED, SIGNATURE_MODE_VARIABLE]
  end
end