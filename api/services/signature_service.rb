require 'ecdsa'
require 'securerandom'
require 'base64'
require 'openssl'

class SignatureService

  GROUP = ECDSA::Group::Secp256k1

  def validate_signature(digest, signature, public_key)
    decoded_public_key = decode_public_key public_key
    ECDSA.valid_signature? decoded_public_key, digest, signature
  end

  def create_sha2_digest(message)
    Digest::SHA2.digest(message)
  end

  def sign(digest, secret_key)
    signature = nil

    while signature.nil?
      temp_key = 1 + SecureRandom.random_number(GROUP.order - 1)
      decoded_private_key = decode_private_key secret_key
      signature = ECDSA.sign(GROUP, decoded_private_key, digest, temp_key.to_i)
    end

    signature
  end

  # This generates a private/public key pair, both of which are base64 encoded.
  def generate_key_pair
    unencoded_private_key = 1 + SecureRandom.random_number(GROUP.order - 1)

    encoded_private_key = create_encoded_private_key unencoded_private_key
    encoded_public_key = create_encoded_public_key unencoded_private_key

    {secret: encoded_private_key, :public => encoded_public_key}
  end

  # This method is specific to CryptoCoinJS signed messages. Uses OpenSSL only
  def validate_cryptocoin_js_signature(digest, signature, public_key)
    decoded_signature = Base64.decode64 signature
    decoded_digest = Base64.decode64 digest
    decoded_public_key = Base64.decode64 public_key

    group_name = 'secp256k1'

    curve = OpenSSL::PKey::EC.new(group_name)
    key_bn = OpenSSL::BN.new(decoded_public_key, 2)
    group = OpenSSL::PKey::EC::Group.new(group_name)
    curve.public_key = OpenSSL::PKey::EC::Point.new(group, key_bn)

    curve.dsa_verify_asn1(decoded_digest, decoded_signature)
  end

  private
  def create_encoded_private_key(unencoded_private_key)
    # create secret key (integer), then convert to string and base64 encode it
    binary_private_key = ECDSA::Format::IntegerOctetString.encode unencoded_private_key, 32
    (Base64.encode64 binary_private_key).chomp
  end

  private
  def create_encoded_public_key(unencoded_private_key)
    # create public key co-ordinates (point), then convert to string and base64 encode it
    public_key = GROUP.generator.multiply_by_scalar(unencoded_private_key)
    binary_public_key = ECDSA::Format::PointOctetString.encode(public_key, compression: true)
    (Base64.encode64 binary_public_key).chomp
  end

  private
  def decode_private_key(key)
    # base64decode the secret key, then convert from binary to integer
    decoded_private_key = Base64.decode64 key
    ECDSA::Format::IntegerOctetString.decode decoded_private_key
  end

  private
  def decode_public_key(key)
    # decode public key
    decoded_public_key = Base64.decode64 key
    ECDSA::Format::PointOctetString.decode decoded_public_key, GROUP
  end

end