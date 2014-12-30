require 'securerandom'
require 'base64'
require 'openssl'

class EcdsaUtil
  def create_key_pair
    group_name = 'secp256k1'

    curve = OpenSSL::PKey::EC.new(group_name)
    curve.generate_key

    public_key = curve.public_key
    private_key = curve.private_key

    {:pk => public_key, :sk => private_key}

  end

  def encode_public_key(public_key)
    # get the big number ("bn") of the public key, and then get the base2 (binary) string of it
    pk_bn_bin = public_key.to_bn.to_s(2)
    # public_key = pk_bn_bin.unpack('H*')[0]

    Base64.encode64 pk_bn_bin
  end

  def encode_private_key(private_key)
    sk_bn_bin = private_key.to_s(2)
    Base64.encode64 sk_bn_bin
  end

  def encode_data(data)
    Base64.encode64 data
  end

  def encode_signature(signature)
    Base64.encode64 signature
  end

  def sign(encoded_data, encoded_private_key)
    group_name = 'secp256k1'

    decoded_data = Base64.decode64 encoded_data
    decoded_private_key = Base64.decode64 encoded_private_key

    curve = OpenSSL::PKey::EC.new(group_name)
    curve.private_key = OpenSSL::BN.new(decoded_private_key, 2)

    curve.dsa_sign_asn1 decoded_data
  end

  def validate_signature(encoded_digest, encoded_signature, encoded_public_key)
    decoded_signature = Base64.decode64 encoded_signature
    decoded_digest = Base64.decode64 encoded_digest
    decoded_public_key = Base64.decode64 encoded_public_key

    group_name = 'secp256k1'

    curve = OpenSSL::PKey::EC.new(group_name)
    key_bn = OpenSSL::BN.new(decoded_public_key, 2)
    group = OpenSSL::PKey::EC::Group.new(group_name)
    curve.public_key = OpenSSL::PKey::EC::Point.new(group, key_bn)

    curve.dsa_verify_asn1(decoded_digest, decoded_signature)
  end
end