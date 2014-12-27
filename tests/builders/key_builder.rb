require_relative '../../api/utils/ecdsa_util'

class KeyBuilder

  def build_pair
    ecdsa_util = EcdsaUtil.new
    key_pair = ecdsa_util.create_ecdsa_key_pair
    public_key = key_pair[:pk]
    secret_key = key_pair[:sk]

    {:sk => (ecdsa_util.encode_private_key secret_key), :pk => (ecdsa_util.encode_public_key public_key)}

  end
end