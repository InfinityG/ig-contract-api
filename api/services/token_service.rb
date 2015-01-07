require './api/utils/key_provider'

class TokenService
  def get_admin_key
    KeyProvider.new.get_admin_key
  end
end