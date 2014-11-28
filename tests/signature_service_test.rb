require 'minitest'
require 'minitest/autorun'

require_relative '../api/services/signature_service'

class SignatureServiceTest < MiniTest::Test

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Fake test
  def test_fail

    fail('Not implemented')
  end

  def test_generates_key_pair
    result = SignatureService.new.generate_key_pair

    assert result[:secret] != nil
    assert result[:public] != nil
  end

  def test_signature_validates_true
    signature_service = SignatureService.new

    # these keys were originally generated through the generate_key_pair method of SignatureService
    public_key = 'A3trKl3ekTUl/bNJJ9+LzK0NvKU3cv7g3oJMEOCu8jl4'
    secret_key = 'oT0Rdy/1mxPdmjg0/3EnmUZp9kFg8WE5xlA8cPrU8hw='

    test_message = '{"conditions":[{"description":"test description", "name":"test name"}]}'
    message_digest = signature_service.create_sha2_digest test_message
    signed_digest = signature_service.sign message_digest, secret_key

    assert signature_service.validate_signature message_digest, signed_digest, public_key

  end

  def test_signature_validates_false_when_secret_key_modified
    signature_service = SignatureService.new

    # these keys were originally generated through the generate_key_pair method of SignatureService
    public_key = 'A3trKl3ekTUl/bNJJ9+LzK0NvKU3cv7g3oJMEOCu8jl4'
    secret_key = 'PT0Rdy/1mxPdmjg0/3EnmUZp9kFg8WE5xlA8cPrU8hw='

    test_message = '{"conditions":[{"description":"test description", "name":"test name"}]}'
    message_digest = signature_service.create_sha2_digest test_message
    signed_digest = signature_service.sign message_digest, secret_key

    result = signature_service.validate_signature message_digest, signed_digest, public_key
    assert (!result)

  end

  def test_signature_validates_false_when_message_tampered
    signature_service = SignatureService.new

    # these keys were originally generated through the generate_key_pair method of SignatureService
    public_key = 'A3trKl3ekTUl/bNJJ9+LzK0NvKU3cv7g3oJMEOCu8jl4'
    secret_key = 'oT0Rdy/1mxPdmjg0/3EnmUZp9kFg8WE5xlA8cPrU8hw='

    test_message = '{"conditions":[{"description":"test description", "name":"test name"}]}'
    message_digest = signature_service.create_sha2_digest test_message
    signed_digest = signature_service.sign message_digest, secret_key

    tampered_test_message = '{"conditions":[{"description":"test description", "name":"NEW test name"}]}'
    tampered_message_digest = signature_service.create_sha2_digest tampered_test_message

    result = signature_service.validate_signature tampered_message_digest, signed_digest, public_key
    assert (!result)

  end
end