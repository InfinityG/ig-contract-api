class Contract
  include MongoMapper::Document

  key :name, String, :required => true
  key :description, String, :required => true
  key :expires, Integer, :required => true

  many :conditions
  many :participants
  many :master_signatures

end