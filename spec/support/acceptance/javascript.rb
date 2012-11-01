RSpec.configure do |config|
  config.before(:each) do
    if example.metadata[:js]
      Capybara.current_driver = case example.metadata[:js]
                                when true, :poltergeist
                                  :poltergeist
                                when :webkit
                                  :webkit
                                end
    end
  end

  config.after(:each) do
    Capybara.use_default_driver if example.metadata[:js]
  end
end
