require_relative '../../../../api/utils/hash_generator'
require_relative '../../../../api/utils/rest_util'
require_relative '../../../../api/utils/ecdsa_util'
require 'json'

class ContractBuilder

  def initialize
  end

  def with_description(description)
    @contract_description = description
    self
  end

  def with_name(name)
    @contract_name = name
    self
  end

  def with_expires(expires)
    @expires = expires
    self
  end

  def with_signatures(signatures)
    @signatures = signatures
    self
  end

  def with_participants(participants)
    @participants = participants
    self
  end

  def with_conditions(conditions)
    @conditions = conditions
    self
  end

  def build
    {
        :name => @contract_name,
        :description => @contract_description,
        :expires => @expires,
        :participants => @participants,
        :signatures => @signatures,
        :conditions => @conditions
    }
  end

  # def create_contract_signatures(participants)
  #   signatures_arr = []
  #
  #   # signatures for creator only in this example
  #   participant = participants.detect do |participant|
  #     participant[:role] == 'creator'
  #   end
  #
  #   signatures_arr << {:participant_external_id => participant[:external_id]}
  #   signatures_arr
  # end

end