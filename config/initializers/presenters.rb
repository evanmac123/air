ruby_files = Rails.root.join('app', 'presenters', '**', '*.rb')

Dir.glob(ruby_files).each do |file|
  require file
end
