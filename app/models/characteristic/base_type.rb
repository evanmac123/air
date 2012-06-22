class Characteristic::BaseType
  def self.format_value(value)
    value.to_s
  end

  def self.cast_value(value)
    value
  end

  # When rendering a form that allows an admin to change a characteristic of
  # this type, what input element should be rendered?
  def self.input_type
    :text
  end

  def self.ensure_operator_applicable(operator_class)
    raise User::NonApplicableSegmentationOperatorError unless allowed_operators.include?(operator_class)
  end

  def self.allowed_operator_names
    allowed_operators.map(&:human_name)
  end

  def self.respect_allowed_values?
    false
  end

  class << self
    # The following is stolen from delayed_job
    yaml_as "tag:ruby.yaml.org,2002:module"

    def self.yaml_new(klass, tag, val)
      val.constantize
    end

    def to_yaml(options = {})
      YAML.quick_emit(nil, options) do |out|
        out.scalar(taguri, name, :plain)
      end
    end

    def yaml_tag_read_class(name)
      # Constantize the object so that ActiveSupport can attempt
      # its auto loading magic. Will raise LoadError if not successful.
      name.constantize
      name
    end
  end
end
