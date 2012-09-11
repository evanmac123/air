if defined?(RSpec)
  module RSpec::Core
    class Example
      # around alias (p 133 Metaprogramming Ruby)
      alias run_after_each_no_logging run_after_each
      def run_after_each

        # Print the filename where the error occurred
        if @exception && @example_block
          as_string = @example_block.to_s
          filename = as_string.match(/spec.*$/).to_s.sub('>', '')
          puts "==> " + @exception.message + " in " + filename.red
        end

        # Print the class of the model that is throwing a save error
        if @exception.kind_of? ActiveRecord::RecordInvalid
          field_name = @exception.to_s.split("Validation failed:").last.strip.split.first.downcase
          begin
            field_value = @exception.record.send(field_name.downcase.to_sym)
          rescue
            field_value = "??"
          end
          msg = "Error attempting to save a #{@exception.record.class.model_name} with #{field_name} '#{field_value}'."
          puts msg.blue
        end

        run_after_each_no_logging
      end
    end
  end
end
