require './api/gateway/ripple_rest_gateway'

class ConfigurationService
  def get_config
    #
    # ripple_gateway = RippleRestGateway.new
    # balances = ripple_gateway.get_wallet_balances
    #
    # {
    #     :gateway_hot_wallet => GATEWAY_HOT_WALLET_ADDRESS,
    #     :gateway_cold_wallet => GATEWAY_COLD_WALLET_ADDRESS,
    #     :gateway_customer_wallet => CUSTOMER_WALLET_ADDRESS,
    #     :gateway_hot_balances => balances[:hot_wallet_balances],
    #     :gateway_cold_balances => balances[:cold_wallet_balances],
    #     :gateway_customer_balances => balances[:customer_wallet_balances],
    #     :ripple_rest_uri => RIPPLE_REST_URI
    # }

  end
end