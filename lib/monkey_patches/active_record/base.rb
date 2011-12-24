class ActiveRecord::Base
  def self.has_alphabetical_column(column_name)
    class_eval <<-END_CLASS_EVAL
      def self.alphabetical
        order("#{column_name} ASC")
      end
    END_CLASS_EVAL
  end
end
