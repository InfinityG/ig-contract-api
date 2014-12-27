class SecretBuilder

  def initialize
    @fragments = []
  end

  def with_fragment(fragment)
    @fragments << fragment
    self
  end

  def with_fragments(fragments)
    @fragments.concat fragments
    self
  end

  def with_threshold(threshold)
    @threshold = threshold
    self
  end

  def build
    {:fragments => @fragments, :threshold => @threshold}
  end
end