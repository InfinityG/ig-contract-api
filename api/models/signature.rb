require './api/models/condition'

class Signature
  include DataMapper::Resource

  property :id, Serial, :key => false
  property :uuid, String, :key => true

  property :origin_wallet_address, String
  property :origin_wallet_tag, String
  property :public_signing_key, String
  property :signature, String
  property :approved, Boolean

  # belongs_to :condition, :parent_key => [:condition_uuid], :child_key => [:uuid], :required => false
  belongs_to :condition, :required => false
end