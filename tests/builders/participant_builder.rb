
class ParticipantBuilder

  def with_external_id(id)
    @external_id = id
    self
  end

  def with_roles(roles)
    @roles = roles
    self
  end

  def with_public_key(key)
    @public_key = key
    self
  end

  def with_wallet(wallet)
    @wallet = wallet
    self
  end

  def build
    {
        :external_id => @external_id,
        :roles => @roles,
        :public_key => @public_key,
        :wallet => @wallet
    }
  end

end