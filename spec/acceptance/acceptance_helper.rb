require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require "steak"

# Put this here so that helper files can throw methods into SteakHelperMethods.
#
RSpec.configuration.include SteakHelperMethods, :type => :acceptance

include SteakHelperMethods
include NavigationHelpers
include TileHelpers
include BoardSwitchingHelpers
