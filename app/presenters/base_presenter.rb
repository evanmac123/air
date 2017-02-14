class BasePresenter
  def initialize(object, template, options)
    @object = object
    @template = template
    @is_ie = options[:is_ie] || false
  end

private

  def self.presents(name)
    define_method(name) do
      @object
    end
  end

  def h
    @template
  end

  def from_search?
    false
  end

  def method_missing(*args, &block)
    @template.send(*args, &block)
  end
end
