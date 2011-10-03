ruby_files = Rails.root.join('lib', 'monkey_patches', '*.rb')

Dir.glob(ruby_files).each do |file|
  require file
end

require Rails.root.join('lib', 'monkey_patches', 'active_record', 'relation')
