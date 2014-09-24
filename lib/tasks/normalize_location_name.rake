task :normalize_location_name => :environment do
  Location.reset_all_normalized_names!
end
