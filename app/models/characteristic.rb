class Characteristic < ActiveRecord::Base
  belongs_to :demo

  validates_uniqueness_of :name

  serialize :allowed_values, Array

  def self.agnostic
    where(:demo_id => nil)
  end

  def self.generic
    where(:demo_id => nil)
  end

  def self.in_demo(demo)
    where(:demo_id => demo.id)
  end
end
