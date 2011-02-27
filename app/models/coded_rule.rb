class CodedRule < Rule
  validates_presence_of :description

  protected

  def require_key?
    false
  end
end
