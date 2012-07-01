class SpecialCommandHandlerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def copy_special_command_handler_file
    template "special_command_handler.rb.erb", "app/models/special_command_handlers/#{file_name}_handler.rb"
  end
end
