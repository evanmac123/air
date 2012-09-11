# A sample Guardfile
# More info at https://github.com/guard/guard#readme

# Use guard-livereload to automatically reload your browser when view files or stylesheets change
# :api_version => '2.0'
guard 'livereload' do
  watch(%r{app/views/.+\.(erb|haml|slim)})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)/assets/\w+/(.+\.(css|js|html)).*})  { |m| "/assets/#{m[2]}" }
end

# Use guard-spork to start spork for us in the background
# and restart spork if anything big changes
guard 'spork', :cucumber => false, :rspec_env => { 'RAILS_ENV' => 'test' } do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch('config/environments/test.rb')
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb')
end

# Use guard-rspec to actually run our tests
run_all = false
run_via_spork = true

options = run_all ? {} : {:all_after_pass => false, :all_on_start => false}
options[:cli] = '--drb --fail-fast' if run_via_spork # pass in the --drb flag 
options[:wait] = 200  # it takes longer than the allowed 30 seconds to load our env

guard 'rspec', {:version => 2}.merge(options) do
  # If a spec itself changes, run that spec
  watch(%r{^spec/.+_spec\.rb$})

  # Support files
  #watch('spec/spec_helper.rb')  { "spec" }
  #watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  
  # Capybara request specs
  watch(%r{^app/views/(.+)/.*\.(erb|haml)$})          { |m| "spec/requests/#{m[1]}_spec.rb" }
  
  # Controllers
  #watch('app/controllers/application_controller.rb')  { "spec/controllers" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb})  { |m| "spec/controllers/#{m[1]}_controller_spec.rb" }
  
  # Models
  watch(%r{^app/models/(.+)\.rb})  { |m| "spec/models/#{m[1]}_spec.rb" }

  # Helpers
  watch(%r{^app/helpers/(.+)_helper\.rb})  { |m| "spec/helpers/#{m[1]}_helper_spec.rb" }

  # Routing
  # watch('config/routes.rb')                           { "spec/routing" }
  
  # Lib
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }

  #Miscellaneous
  watch(%r{^app/views/mailer/invitation.+$}) { "spec/mailers/invitation_email_spec.rb" }
  watch(%r{^app/views/email_previews.+$}) { "spec/mailers/invitation_email_spec.rb" }
end




