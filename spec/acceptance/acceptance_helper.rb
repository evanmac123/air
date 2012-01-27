require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require "steak"

# Put your acceptance spec helpers inside /spec/acceptance/support
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

# Put this here so that helper files can throw methods into SteakHelperMethods.
#
RSpec.configuration.include SteakHelperMethods, :type => :acceptance
