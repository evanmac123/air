class Characteristic < ActiveRecord::Base
  belongs_to :demo

  serialize :allowed_values, Array
end
