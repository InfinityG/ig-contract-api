require './api/utils/rest_util'
require './api/utils/key_provider'
require 'json'
require 'uri'

class RippleRestGateway
  def create_trust_line(ripple_address, ripple_secret, limit, currency, counterparty_address)
    uri = "#{RIPPLE_REST_URI}/v1/accounts/#{ripple_address}/trustlines"
    payload = {:secret => ripple_secret,
               :trustline => {:limit => limit,
                              :currency => currency,
                              :counterparty => counterparty_address,
                              :allows_rippling => false}}

    result = rest_util_instance.execute_post uri, payload
    json = JSON.parse result.response_body
    json['success']
  end

  # Payments from gateway hot wallet to customer wallet
  def create_deposit(resource_id, payment)
    uri = "#{RIPPLE_REST_URI}/v1/payments"
    payload = {:secret => GATEWAY_HOT_WALLET_SECRET, :client_resource_id => resource_id, :payment => payment}.to_json
    result = rest_util_instance.execute_post uri, payload
    json = JSON.parse result.response_body

    unless json['success']
      return json['message']
    end

    URI(json['status_url']).path

  end

  # Payments from gateway customer wallet to gateway hot wallet
  def create_withdrawal(resource_id, payment)
    uri = "#{RIPPLE_REST_URI}/v1/payments"
    payload = {:secret => CUSTOMER_WALLET_SECRET, :client_resource_id => resource_id, :payment => payment}.to_json
    result = rest_util_instance.execute_post uri, payload
    json = JSON.parse result.response_body

    unless json['success']
      return json['message']
    end

    URI(json['status_url']).path
  end

  def prepare_deposit(tag, amount, memo)
    #destination_amount = amount+currency+issuer (issuer is the cold wallet)
    destination_amount = "#{amount}+#{DEFAULT_CURRENCY}+#{GATEWAY_COLD_WALLET_ADDRESS}"
    uri = "#{RIPPLE_REST_URI}/v1/accounts/#{GATEWAY_HOT_WALLET_ADDRESS}/payments/paths/#{CUSTOMER_WALLET_ADDRESS}/#{destination_amount}"

    execute_preparation_request uri, tag, memo
  end

  # from customer wallet to gateway wallet
  def prepare_withdrawal(tag, amount, memo)
    #destination_amount = amount+currency+issuer (issuer is the cold wallet)
    destination_amount = "#{amount}+#{DEFAULT_CURRENCY}+#{GATEWAY_COLD_WALLET_ADDRESS}"
    uri = "#{RIPPLE_REST_URI}/v1/accounts/#{CUSTOMER_WALLET_ADDRESS}/payments/paths/#{GATEWAY_HOT_WALLET_ADDRESS}/#{destination_amount}"

    execute_preparation_request uri, tag, memo
  end

  def confirm_transaction(status_path)
    result = rest_util_instance.execute_get status_path
    json = JSON.parse result.response_body

    {
        :status => json['payment']['state'],
        :result => json['payment']['result'],
        :ledger_id => json['payment']['ledger'].to_i,
        :ledger_hash => json['payment']['hash'],
        :ledger_timestamp => json['payment']['timestamp'],
        :amount => json['payment']['destination_amount']['value'].to_i,
        :currency => json['payment']['destination_amount']['currency']
    }

  end

  def get_wallet_balances
    #GET /v1/accounts/{:address}/balances
    hot_wallet_uri = "#{RIPPLE_REST_URI}/v1/accounts/#{GATEWAY_HOT_WALLET_ADDRESS}/balances"
    cold_wallet_uri = "#{RIPPLE_REST_URI}/v1/accounts/#{GATEWAY_COLD_WALLET_ADDRESS}/balances"
    customer_wallet_uri = "#{RIPPLE_REST_URI}/v1/accounts/#{CUSTOMER_WALLET_ADDRESS}/balances"

    hot_result = rest_util_instance.execute_get hot_wallet_uri
    cold_result = rest_util_instance.execute_get cold_wallet_uri
    customer_result = rest_util_instance.execute_get customer_wallet_uri

    hot_json = JSON.parse hot_result.response_body
    cold_json = JSON.parse cold_result.response_body
    customer_json = JSON.parse customer_result.response_body

    hot_balances = [] 
    hot_json['balances'].each { |balance|
      if balance['currency'] == DEFAULT_CURRENCY
        hot_balances.push balance
      end
    }

    cold_balances = []
    cold_json['balances'].each { |balance|
      if balance['currency'] == DEFAULT_CURRENCY
        cold_balances.push balance
      end
    }

    customer_balances = []
    customer_json['balances'].each { |balance|
      if balance['currency'] == DEFAULT_CURRENCY
        customer_balances.push balance
      end
    }

    {:hot_wallet_balances => hot_balances, :cold_wallet_balances => cold_balances, :customer_wallet_balances => customer_balances}

  end

  #### HELPERS ###

  private
  def execute_preparation_request(uri, tag, memo)
    result = rest_util_instance.execute_get uri
    json = JSON.parse result.response_body

    if json['success']
      return update_payment_details json, tag, memo
    end

    raise 'Payment preparation unsuccessful!'

  end

  private
  def update_payment_details(json, tag, memo)
    payment = json['payments'][0]
    payment['source_tag'] = tag
    payment['source_amount']['issuer'] = GATEWAY_COLD_WALLET_ADDRESS
    payment['destination_tag'] = tag
    payment['destination_amount']['issuer'] = GATEWAY_COLD_WALLET_ADDRESS
    payment['memos'] = [{:MemoType => 'Payment description', :MemoData => memo}] #TODO: check this works!
    payment
  end

  private
  def rest_util_instance
    @rest_util = RestUtil.new if @rest_util == nil
    @rest_util
  end

end