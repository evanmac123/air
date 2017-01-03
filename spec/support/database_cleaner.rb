# NOTE: This is still a weird configuration.  Let's revisit after RSpec/Rails  upgrades.
RSpec.configure do |config|
  config.before(:suite) do
    if config.use_transactional_fixtures?
      raise(<<-MSG)
        Delete line `config.use_transactional_fixtures = true` from spec_helper.rb or rails_helper.rb
        (or set it to false) to prevent uncommitted transactions being used in
        JavaScript-dependent specs.
      MSG
    end
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    if example.metadata[:driver]
      DatabaseCleaner.strategy = :transaction
    else
      DatabaseCleaner.strategy = :deletion, {pre_count: true}
    end

    DatabaseCleaner.cleaning do
      example.run
    end

    Capybara.use_default_driver
  end
end
