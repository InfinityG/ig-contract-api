class SignatureBuilder

  def with_participant_external_id(id)
    @participant_external_id = id
    self
  end

  def with_type(type)
    @type = type
    self
  end

  def build
    {:participant_external_id => @participant_external_id, :type => @type}
  end
end