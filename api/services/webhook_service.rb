require './api/utils/rest_util'
require './api/constants/error_constants'
require './api/errors/contract_error'

class WebHookService

  include ErrorConstants::ContractErrors

  def process_webhook(webhook)
    puts "Processing webhook:#{webhook.id}; uri:#{webhook.uri}"

    # TODO: implement the requests using RestUtil!

    uri = webhook[:uri]
    method = webhook[:method].to_s.downcase
    headers = webhook[:headers]
    body = webhook[:body]

    rest_client = RestUtil.new

    case method
      when 'post'
        rest_client.execute_post uri, headers[0], body
      when 'get'
        rest_client.execute_get uri, headers[0]
      else
        raise ContractError, INVALID_WEBHOOK_METHOD
    end

  end
end