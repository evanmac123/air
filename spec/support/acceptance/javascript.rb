# If you want to use capy-webkit instead of Poltergeist just use ":js => :webkit" instead of ":js => true" in your scenario definition.
# Selenium is also available but you shouldn't use that on a regular basis, we don't have all day.
# Also, if you want the super-duper debug output, change ':webkit' down below to ':webkit_debug'

RSpec.configure do |config|
  config.before(:each) do
    if example.metadata[:js]
      Capybara.current_driver = if example.metadata[:js] == true
                                  :poltergeist
                                else
                                  example.metadata[:js] 
                                end
    end
  end

  config.after(:each) do
    Capybara.use_default_driver if example.metadata[:js]
  end
end
