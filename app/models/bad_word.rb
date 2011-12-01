class BadWord < ActiveRecord::Base
  belongs_to :demo

  def self.reachable_from_demo(demo)
    where("demo_id IS NULL OR demo_id = ?", demo.id)
  end

  def self.including_any_word(words)
    where(:value => words)
  end

  def self.generic
    where(:demo_id => nil)
  end

  def self.alphabetical
    order("value")
  end
end
