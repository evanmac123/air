class BasePresenter
  def initialize(object, template, options)
    @object = object
    @template = template
    @as_admin =options[:as_admin] || false
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
  
  def method_missing(*args, &block)
    @template.send(*args, &block)
  end
end
