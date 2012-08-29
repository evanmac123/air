module RSpec::Core
  class Example
    # around alias (p 133 Metaprogramming Ruby)
    alias run_after_each_no_logging run_after_each
    def run_after_each
      if @exception && @example_block
        as_string = @example_block.to_s
        filename = as_string.match(/spec.*$/).to_s.sub('>', '')
        puts "==> " + @exception.message + " in " + filename.red
      end
      run_after_each_no_logging
    end
  end
end
