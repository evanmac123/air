# If you want to use capy-webkit instead of Poltergeist just use ":js => :webkit" instead of ":js => true" in your scenario definition.
# Also, if you want the super-duper debug output, change ':webkit' down below to ':webkit_debug'

RSpec.configure do |config|
  config.before(:each) do
    if example.metadata[:js]
      Capybara.current_driver = case example.metadata[:js]
                                  when true, :poltergeist then :poltergeist
                                  when :webkit            then :webkit
                                end
    end
  end

  config.after(:each) do
    Capybara.use_default_driver if example.metadata[:js]
  end
end
