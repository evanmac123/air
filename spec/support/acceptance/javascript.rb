# Note that there is a "  Capybara.javascript_driver = :webkit" line in '/spec_helper.rb'
# Don't know why or what the priority is, but if you're going to set ':webkit' to ':webkit_debug' you probably better do both.
RSpec.configure do |config|
  config.before(:each) do
    if example.metadata[:js]
      Capybara.current_driver = case example.metadata[:js]
                                when true, :poltergeist
                                  :poltergeist
                                when :webkit
                                  :poltergeist
                                end
      #Capybara.current_driver = case example.metadata[:js]
      #                          when :poltergeist
      #                            :poltergeist
      #                          when true, :webkit
      #                            :webkit_debug
      #                          end
    end
  end

  config.after(:each) do
    Capybara.use_default_driver if example.metadata[:js]
  end
end
