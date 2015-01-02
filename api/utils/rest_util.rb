require 'rest_client'

class RestUtil

  def execute_get(api_uri)
    puts "Uri: #{api_uri}"

    client = get_client api_uri
    response = client.get(:content_type => 'application/json;charset=UTF-8', :verify_ssl => false)

    build_response(response)
  end

  def execute_post(api_uri, json = '')
    puts "Request uri: #{api_uri}"
    puts "Request JSON: #{json}"

    # client = get_client api_uri
    client = RestClient::Resource.new api_uri

    response = begin
      client.post(json, :content_type => 'application/json;charset=UTF-8', :verify_ssl => false)
    rescue => e
        return build_response e.response
    end

    build_response(response)
  end

  def build_response(response)
    rest_response = RestResponse.new
    rest_response.response_code = response.code
    rest_response.response_body = response.body

    puts "Response code: #{response.code}"
    puts "Response JSON: #{response.body}"
    puts ''

    rest_response
  end

  def get_client(uri)
    RestClient::Resource.new(uri, :user => GATEWAYD_ADMIN_USER, :password => GATEWAYD_KEY, :timeout => settings.default_request_timeout)
  end

end

class RestResponse
  attr_accessor :response_code
  attr_accessor :response_body
end