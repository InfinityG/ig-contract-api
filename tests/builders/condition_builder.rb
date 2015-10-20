class ConditionBuilder

  def initialize
    @signature_arr = []
  end

  def with_name(name)
    @name = name
    self
    end

  def with_description(description)
    @description = description
    self
  end

  def with_sequence_number(number)
    @sequence_number = number
    self
  end

  def with_signatures(signatures)
    @signature_arr.concat signatures
    self
  end

  def with_trigger(trigger)
    @trigger = trigger
    self
  end

  def with_expires(expires)
    @expires = expires
    self
  end

  def build
    {
        :name => @name,
        :description => @description,
        :sequence_number => @sequence_number,
        :signatures => @signature_arr,
        :sig_mode => @signature_mode,
        :trigger => @trigger,
        :expires => @expires
    }
  end

  def with_signature_mode(signature_mode)
    @signature_mode = signature_mode
    self
  end
end