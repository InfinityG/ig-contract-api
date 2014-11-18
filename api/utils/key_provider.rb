require 'base64'

class KeyProvider
  def get_key
    key = Base64.strict_encode64("#{GATEWAYD_ADMIN_USER}:#{GATEWAYD_KEY}").chomp  #.gsub('=', '')
    puts key
    key
  end
end