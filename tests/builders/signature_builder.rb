class SignatureBuilder

  def with_participant_external_id(id)
    @participant_external_id = id
    self
  end

  def with_type(type)
    @type = type
    self
    end

  def with_delegated_by_external_id(id)
    @delegated_by_external_id = id
    self
  end

  def with_value(value)
    @value = value
    self
  end

  def with_digest(digest)
    @digest = digest
    self
  end

  def build
    return {:value => @value, :digest => @digest} if @value != nil || @digest != nil

      {:participant_external_id => @participant_external_id, :type => @type,
     :delegated_by_external_id => @delegated_by_external_id}
  end

end