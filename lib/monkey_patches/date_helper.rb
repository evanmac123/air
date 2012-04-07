module ActionView
  module Helpers
    module DateHelper
      def select_hour_with_twelve_hour_time(datetime, options = {}, html_options={})        
        return select_hour_without_twelve_hour_time(datetime, options, html_options) unless options[:twelve_hour].eql? true

        val = datetime ? (datetime.kind_of?(Fixnum) ? datetime : datetime.hour) : ''

        if options[:use_hidden]
          hidden_html(options[:field_name] || 'hour', val, options)
        else
          if options[:field_name] && options[:prefix]
            unless options[:id]
              normalized_field_name = options[:field_name].gsub(/\(/, '_').gsub(/\)/, '')
              options[:id] = "#{options[:prefix]}_#{normalized_field_name}"
            end

            unless options[:name]
              options[:name] = "#{options[:prefix]}[#{options[:field_name]}]"
            end
          end

          select_tag(options[:field_name] || 'hour', twelve_hour_option_tags(val), options)
        end
      end
# ************  YOU WON'T NEED THIS IN RAILS 3.1 ***********************************
# Right when you think you need to change this to use 'super', you can just use the
# :ampm => true option in rails 3.1
      alias_method_chain :select_hour, :twelve_hour_time

      def twelve_hour_option_tags(val)
        hour_options = []
        0.upto(23) do |hour|
          ampm = hour <= 11 ? ' AM' : ' PM'
          ampm_hour = (hour == 0 || hour == 12) ? 12 : (hour / 12 == 1 ? hour % 12 : hour)

          hour_options << ((val == hour) ?
            %(#{ampm_hour}#{ampm}) :
            %(#{ampm_hour}#{ampm})
          )
        end

        options_from_collection_for_select((0..23).zip(hour_options), :first, :second)
      end
    end
  end
end

