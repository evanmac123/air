module Airbrake
  class Notice

    alias original_initialize initialize

    def initialize(args)
      original_initialize(args)
      begin
        # Send custom parameters to Airbrake to assist in debugging
        # If an airbrake shows up without these parameters, you
        # may have an exception in this "begin" block
        custom = self.parameters

        current_user = args[:cgi_data][:clearance].current_user
        current_user_data = current_user ? current_user.to_yaml : 'no current user'

        custom.merge!(note: 'edit which parameters get sent at lib/monkey_patches/airbrake/notice.rb')
        custom.merge!(current_user: current_user_data)
        self.parameters = custom
      rescue
      end
    end
  end
end
