require 'ig-crypto-utils'
require 'base64'

class KeyBuilder

  def build_pair
    key_pair = CryptoUtils::EcdsaUtil.new.create_key_pair
    public_key = key_pair[:pk]
    secret_key = key_pair[:sk]

    {:sk => secret_key, :pk => public_key}

  end
end