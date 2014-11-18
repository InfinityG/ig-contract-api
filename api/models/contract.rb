class Contract
  include DataMapper::Resource

  property :id, Serial, :key => false
  property :uuid, String,  :key => true

  property :public_key, String
  property :private_key, String
  property :signature, String

  property :user_id, Integer

  property :name, String
  property :description, String
  property :expires, Integer
  property :target_wallet_address, String
  property :target_wallet_tag, String
  property :value, Integer
  property :status, String

  has n, :conditions
end