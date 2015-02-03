require './api/utils/key_provider'
require './api/services/hash_service'
require './api/repositories/token_repository'
require './api/repositories/user_repository'

class TokenService

  def initialize(key_provider = KeyProvider, hash_service = HashService,
                 token_repository = TokenRepository, user_repository = UserRepository)
    @key_provider = key_provider.new
    @hash_service = hash_service.new
    @token_repository = token_repository.new
    @user_repository = user_repository.new
  end

  def get_admin_key
    @key_provider.get_admin_key
  end

  # create a token for an existing user
  def create_token(username, password)

    #get the user first and check if the password matches
    user = @user_repository.get_by_username username

    if user != nil
      password_salt = user[:password_salt]
      password_hash = user[:password_hash]

      #now check if the hash matches the password
      result = @hash_service.generate_password_hash password, password_salt

      if result == password_hash
        #all good, now save the token for the user
        uuid = @hash_service.generate_uuid
        return save_token user.id, uuid
        # return uuid
      end

      return nil
    end

    nil
  end

  # create a token for a new user
  def create_token_for_registration(user_id)
    token = @hash_service.generate_uuid
    save_token user_id, token
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
end