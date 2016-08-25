class LeadContactUpdater
  attr_reader :attrs, :lead_contact
  def self.dispatch(attributes, action)
    LeadContactUpdater.new(attributes, action.downcase).execute
  end

  def initialize(attributes, action)
    @attrs = normalize_attribtues(attributes)
    @lead_contact = LeadContact.find(attrs.id)
    @action = action
  end

  def execute
    self.send(@action)
  end

  def update
  end

  def approve
    binding.pry
  end

  def deny
    binding.pry
  end

  private
    def normalize_attribtues(attributes)
      attributes.update(attributes) { |_key, v| v.empty? ? "invalid" : v }
      OpenStruct.new(attributes)
    end
end
