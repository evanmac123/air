module DemoScope
  def self.included(other)
    other.extend(ClassMethods)
  end

  module ClassMethods
    def in_demo(demo)
      where(:demo_id => demo.id)
    end
  end
end
