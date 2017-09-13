module Integrations
  class FullStoryService
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def record_user?
      user_is_guest? || record_active_user?
    end

    private

      def user_is_guest?
        user.nil? || user.is_a?(GuestUser) || user.is_a?(PotentialUser)
      end

      def record_active_user?
        unless user.organization.try(:internal) || user.is_site_admin
          user.is_client_admin || user_is_ordinary_user_in_sample?
        end
      end

      def user_is_ordinary_user_in_sample?
        # Simple sample mechanism to avoid rate limite on FullStory.
        user.end_user? && (user.id % 2 == 0)
      end
  end
end
