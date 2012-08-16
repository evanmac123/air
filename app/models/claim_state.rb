class ClaimState < Struct.new(:finder_method, :next_state_on_ambiguity_id, :ambiguity_message, :unrecognized_information_message, :valid_format, :invalid_format_message, :notify_admins_on_failure, :already_claimed_message)
  def initialize(attributes = {})
    super
    attributes.each do |key, value|
      send("#{key.to_s}=", value)
    end
  end
end
