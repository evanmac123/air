RSpec.configure do |config|
  config.before(:suite) do
    Searchkick.disable_callbacks
  end

  config.around(:each, search: true) do |example|
    Tile.reindex
    Campaign.reindex

    Searchkick.enable_callbacks
    example.run
    Searchkick.disable_callbacks
  end
end
