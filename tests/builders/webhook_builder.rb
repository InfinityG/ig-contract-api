class WebhookBuilder

  def with_uri(uri)
    @uri = uri
    self
    end

  def with_method(method)
    @method = method
    self
  end

  def with_headers(headers)
    @headers = headers
    self
  end

  def with_header(name, value)
    @headers = [] if @headers == nil
    @headers << {:name => name, :value => value}
    self
  end

  def with_payload(payload)
    @payload = payload
    self
  end

  def build
    {:uri => @uri, :method => @method, :headers => @headers, :payload => @payload}
  end
end