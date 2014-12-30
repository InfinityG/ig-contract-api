require 'minitest'
require 'minitest/autorun'
require 'openssl'
require 'base64'

require_relative '../../api/utils/ecdsa_util'

class EcdsaUtilTest < MiniTest::Test
  include OpenSSL

  def test_creates_key_pair
    util = EcdsaUtil.new

    pair = util.create_key_pair

    refute_nil pair[:sk]
    refute_nil pair[:pk]
  end

  def test_base64_encodes_public_key
    util = EcdsaUtil.new

    pair = util.create_key_pair
    encoded_key = util.encode_public_key pair[:pk]

    assert encoded_key != nil
  end

  def test_validates_signature
    util = EcdsaUtil.new

    pair = util.create_key_pair
    data = 'My test data'

    encoded_private_key = util.encode_private_key pair[:sk]
    encoded_public_key = util.encode_public_key pair[:pk]
    encoded_data = util.encode_data data

    # sign the data
    signature = util.sign(encoded_data, encoded_private_key)
    encoded_signature = util.encode_signature signature

    # now validate
    result = util.validate_signature(encoded_data, encoded_signature, encoded_public_key)

    assert result
  end

end