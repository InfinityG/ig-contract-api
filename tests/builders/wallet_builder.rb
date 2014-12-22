class WalletBuilder
  def with_address(address)
    @address = address
    self
  end

  def with_destination_tag(tag)
    @tag = tag
    self
  end

  def with_secret(secret)
    @secret = secret
    self
  end

  def build
    {
        :address => @address,
        :destination_tag => @tag,
        :secret => @secret
    }
  end
end