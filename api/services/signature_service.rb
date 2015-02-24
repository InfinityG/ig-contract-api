
# require './api/utils/ecdsa_util'
require 'ig-crypto-utils'

class SignatureService

  def initialize(ecdsa_util = CryptoUtils::EcdsaUtil)
    @ecdsa_util = ecdsa_util.new
  end

  def sign(encoded_data, encoded_private_key)
    @ecdsa_util.sign encoded_data, encoded_private_key
  end

  def create_key_pair
    @ecdsa_util.create_key_pair
  end

  def validate_signature(encoded_digest, encoded_signature, encoded_public_key)
    @ecdsa_util.validate_signature(encoded_digest, encoded_signature, encoded_public_key)
  end

end