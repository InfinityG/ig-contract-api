class WebhookBuilder

  def with_uri(uri)
    @uri = uri
    self
  end

  def with_payload(payload)
    @payload = payload
    self
  end

  def build
    {:uri => @uri, :payload => @payload}
  end
end