require 'minitest'
require 'minitest/autorun'
require 'openssl'
require 'base64'
require 'json'

# Javascript crypto libraries

# sjcl (http://crypto.stanford.edu/sjcl/)
# crypto-js (https://code.google.com/p/crypto-js/)
# jsCrypto (https://code.google.com/p/jscryptolib/)
# triplesec (https://github.com/keybase/triplesec)
# polycrypt (https://github.com/polycrypt)
# forge (https://github.com/digitalbazaar/forge)
# closure (http://docs.closure-library.googlecode.com/git/namespace_goog_crypt.html)

class OpenSslEcdsaTest < MiniTest::Test
  include OpenSSL

  def test_full_ecdsa_cycle_openssl

    # derived from http://h2np.net/tips/wiki/index.php?RubyOpenSSLDigitalSignatureSample

    group_name = 'secp256k1'
    message = '10000 fartbux sent to bryce from a can of beans'

    # Create keys

    key = PKey::EC.new(group_name)
    key = key.generate_key

    puts 'private'
    puts key.to_text
    puts 'public'
    puts key.public_key.to_bn

    # Create message digest

    digest = Digest::SHA256.digest(message)
    puts 'digest'
    puts Base64.encode64 digest

    # Sign message digest

    signature = key.dsa_sign_asn1 digest
    puts 'signature'
    puts Base64.encode64 signature

    # Now do the validation side of things

    group = PKey::EC::Group.new(group_name)
    point = PKey::EC::Point.new(group, key.public_key.to_bn)
    # verifier = PKey::EC.new(group)
    verifier = key
    verifier.private_key = nil
    verifier.public_key = point
    puts 'verify key'
    puts verifier.to_text


    assert verifier.dsa_verify_asn1(digest, signature)
  end

  def test_validate_crypto_coin_js_signature

    # http://cryptocoinjs.com/modules/crypto/ecdsa/#ecdsa
    # http://stackoverflow.com/questions/22293864/ruby-openssl-convert-elliptic-curve-point-octet-string-into-opensslpkeyec

    # keys and signature generated by CryptoCoinJS (client-side)
    signature = 'MEQCIHfKlBt+Jz+bCeq9Ezk/3xrWk7rKpzxtDCUJGY8KtppYAiBOqfy9syiYse2DFzR+hQNtRZVZmZmHBK8gMUIuuzJFjA=='
    public_key = 'An6MkFx3+QAEFEGePgRi/G0fROp1Q/SUwvCtD7cX+5ym'
    message_digest = 'dQnlvaDHYtK6x/kNdYtbImP6Acy8VCq1498WO+CObKk='

    base64_decoded_signature = Base64.decode64 signature
    base64_decoded_digest = Base64.decode64 message_digest
    base64_decoded_public_key = Base64.decode64 public_key

    public_key_octet_string = base64_decoded_public_key

    curve = OpenSSL::PKey::EC.new('secp256k1')
    key_bn = OpenSSL::BN.new(public_key_octet_string, 2)
    group = OpenSSL::PKey::EC::Group.new('secp256k1')
    curve.public_key = OpenSSL::PKey::EC::Point.new(group, key_bn)

    result = curve.dsa_verify_asn1(base64_decoded_digest, base64_decoded_signature)

    assert result
  end

  def test_experimental
    # Public key (packed and Base64 encoded) - sent from SJCL
    num_arr = [-1639114955, 338522300, -1879416014, 1017985563, 8562349, 853316141, 377373644, 2040249165, -650108940, -1427607380, 766295775, -451763508, -823677701, 819843852, -134916582, 362688979]
    packed_arr = num_arr.pack 'l>*' # pack using signed big endian numbers
    puts "Packed num arr: #{packed_arr}"

    # Public key as it is received from SJCL (we need to Base64 decode it) - THIS IS HOW WE WILL RECEIVE THE KEY
    base64_key = 'nk0XNRQtcLyP+mMyPK06GwCCpq0y3JItFn5DzHmbu03ZQB/0quhwrC2svt/lEqLMzues+zDd0wz39VYaFZ4x0w=='
    decoded_base64_arr = Base64.decode64 base64_key
    puts "Decoded Base64 arr: #{decoded_base64_arr}"
    puts "Unpacked Decoded Base64 arr: #{decoded_base64_arr.unpack 'l>*'}"

    # opening a public key generated with the openssl cli tool showed a structure like this:
    algokey = OpenSSL::ASN1::ObjectId 'id-ecPublicKey'
    algovalue = OpenSSL::ASN1::ObjectId 'secp256k1'
    algo = OpenSSL::ASN1::Sequence.new [algokey, algovalue]
    # for some reason OpenSSL seems to prepend 0x04 to all public keys
    key = OpenSSL::ASN1::BitString.new "\x04#{decoded_base64_arr}"
    root = OpenSSL::ASN1::Sequence.new [algo, key]

    pub = OpenSSL::PKey.read(root.to_der)
    pub_bn = pub.public_key.to_bn
    puts pub_bn # WE NOW HAVE THE KEY!!!!

    #################
    # Now do something similar to the 'test_ecdsa' test above
    group_name = 'secp256k1'

    digest = Base64.decode64 '3eQkDU1iFuvPaZb0C2nuQ0b1U9vKpObhD3+WOTo0pKQ='
    puts digest

    signature = Base64.decode64 'mgHLHwbDsljQA4wsJvvE6U2qzbaS00CbIq+xTU9aBPu/6UKgTDAUF8SmyC66ZZm6TJ0jM+1v0TpZm8CodS73VQ=='
    puts signature

    group = PKey::EC::Group.new(group_name)
    point = PKey::EC::Point.new(group, pub_bn)
    # verifier = PKey::EC.new(group)
    verifier = pub
    verifier.private_key = nil
    verifier.public_key = point

    puts 'verify key'
    puts verifier.to_text

    puts 'verifying:'
    puts verifier.dsa_verify_asn1(digest, signature).inspect

  end
end