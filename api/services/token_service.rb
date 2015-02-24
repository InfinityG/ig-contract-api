require './api/utils/key_provider'
require './api/services/hash_service'
require './api/repositories/token_repository'
require './api/repositories/user_repository'
require './api/services/config_service'

require 'ig-identity-rp-validator'

class TokenService

  def initialize(key_provider = KeyProvider, hash_service = HashService,
                 token_repository = TokenRepository, user_repository = UserRepository,
                 rp_validator = IgIdentity::RelyingParty::AuthValidator,
                 config_service = ConfigurationService)
    @key_provider = key_provider.new
    @hash_service = hash_service.new
    @token_repository = token_repository.new
    @user_repository = user_repository.new
    @rp_validator = rp_validator.new
    @config_service = config_service.new
  end

  def get_admin_key
    @key_provider.get_admin_key
  end

  def create_token(auth, iv)

    validated_auth = validate_auth(auth, iv)
    return nil if validated_auth == nil

    username = validated_auth[:username]
    role = validated_auth[:role]

    user = @user_repository.get_by_username username
    # create the user if not present in db
    user = @user_repository.save_user username, role if user == nil

    uuid = @hash_service.generate_uuid
    save_token user.id, uuid

  end

  def get_token(uuid)
    token = @token_repository.get_token(uuid)

    #check that the token hasn't expired, if it has, delete it
    if token != nil
      if token.expires <= Time.now.to_i
        @token_repository.delete_token uuid
        return nil
      end
      return token
    end

    nil
  end

  private
  def save_token(user_id, token)
    timestamp = Time.now
    expires = timestamp + (60 * 60)

    @token_repository.save_token(user_id, token, expires.to_i)
  end

  private
  def validate_auth(auth, iv)
    # validate the auth payload created by the identity provider
    config = @config_service.get_config
    aes_key = config[:shared_aes_key]
    ecdsa_key = config[:id_provider_public_ecdsa_key]

    auth_result = @rp_validator.validate_auth(auth, iv, aes_key, ecdsa_key)
    # parsed_result = JSON.parse(auth_result, :symbolize_names => true)

    unless auth_result[:valid] && auth_result[:auth][:expiry_date] > Time.now.to_i
      return nil
    end

    auth_result[:auth]

  end
end