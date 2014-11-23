require 'mongo_mapper'

class Transaction
  include MongoMapper::EmbeddedDocument

  key :from_participant, String
  key :to_participant, String
  key :amount, Integer
  key :currency, String
  key :status, String
  key :ledger_transaction_hash, String

end