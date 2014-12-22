require_relative '../../api/utils/ecdsa_util'

class KeyBuilder

  def with_participant_external_id(external_id)
    @external_id = external_id
    self
  end

  def build_hash
    ecdsa_util = EcdsaUtil.new
    key_pair = ecdsa_util.create_ecdsa_key_pair
    public_key = key_pair[:pk]
    secret_key = key_pair[:sk]

    {@external_id => {:sk => secret_key, :pk => (ecdsa_util.encode_public_key public_key)}}

    # @participants.each do |participant|
    #   key_pair = ecdsa_util.create_ecdsa_key_pair
    #   public_key = key_pair[:pk]
    #   secret_key = key_pair[:sk]
    #   key_hash[participant[:external_id]] = {:sk => secret_key, :pk => (ecdsa_util.encode_public_key public_key)}
    # end

    # key_hash
  end
end