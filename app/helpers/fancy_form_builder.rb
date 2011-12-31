class FancyFormBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::TagHelper

  def fancy_text_field(method_name, options={})
    fancy_field(:text_field, method_name, options)
  end

  def fancy_password_field(method_name, options={})
    fancy_field(:password_field, method_name, options)
  end

  protected

  def fancy_field(field_method, method_name, options)
    label_text = options[:label_text]

    outer_wrapper(
      method_name,
      label_wrapper(label(method_name, label_text)) +
      field_wrapper(self.send(field_method, method_name, options)) + 
      error_content(method_name)
    )
  end

  def add_error_class!(method_name, options)
    return unless errors_for_method?(method_name)

    options[:class] = "" if options[:class].empty?
    options[:class] = [options[:class], "status_input"].join(' ')
    options[:class].strip!
    options
  end

  def error_content(method_name)
    return unless errors_for_method?(method_name)
 
    [
      '<li class="form-msg"><p class="msg">',
      h(self.object.errors[method_name].join(', ')), 
      '</p></li>'
    ].join.html_safe
  end

  def errors_for_method?(method_name)
    self.object.errors[method_name].present?
  end

  def label_wrapper(text)
    %{<li class="form-label">#{text}</li>}.html_safe
  end

  def outer_wrapper(method_name, text)
    %{<ul class="form-section signup-#{method_name}">#{text}</ul>}.html_safe
  end

  def field_wrapper(text)
    %{<li class="form-input">#{text}</li>}.html_safe
  end
end
