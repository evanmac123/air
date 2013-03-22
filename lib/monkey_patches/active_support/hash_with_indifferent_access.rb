class ActiveSupport::HashWithIndifferentAccess
  def filter_by_key(*allowed_keys)
    _allowed_keys = allowed_keys.map(&:to_s)
    self.select {|key, value| _allowed_keys.include? key}
  end
end
