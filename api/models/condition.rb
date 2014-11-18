require './api/models/contract'

class Condition
  include DataMapper::Resource

  property :id, Serial, :key => false
  property :uuid, String, :key => true

  property :name, String
  property :description, String
  property :expires, Integer
  property :sequence_number, Integer

  # belongs_to :contract, :parent_key => [:contract_uuid], :child_key => [:uuid], :required => false
  belongs_to :contract, :required => false
  has n, :signatures

end