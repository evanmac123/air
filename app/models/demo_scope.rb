module DemoScope
  def self.included(other)
    other.extend(ClassMethods)
  end

  module ClassMethods
    def in_demo(demo)
      where(:demo_id => demo.id)
    end

    def in_user_demo
      joins(:user).where("users.demo_id = #{table_name}.demo_id")
    end
  end
end
