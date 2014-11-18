require 'securerandom'
require 'digest'

class HashGenerator

  def generate_hash(password, salt)
    salted_password = password + salt
    Digest::SHA2.base64digest salted_password
  end

  def generate_salt
    generate_uuid
  end

  def generate_uuid
    SecureRandom.uuid
  end

  #http://stackoverflow.com/questions/2754449/bitwise-operations-on-strings-with-ruby
  def generate_bitwise_xor

  end
end