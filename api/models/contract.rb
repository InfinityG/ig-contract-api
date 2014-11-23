class Contract
  include MongoMapper::Document

  key :name, String
  key :description, String
  key :expires, Integer

  many :conditions
  many :participants
  many :master_signatures

end