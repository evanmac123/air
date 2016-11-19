module Integrations
  class NetPromoterScore
    #Delighted API docs: https://delighted.com/docs/api
    class << self
      def send_nps_survey(user)
        if post_to_delighted?
          Delighted::Person.create(
            email: user.email,
            name: user.name,
            properties: properties_for_nps(user),
          )
        end
      end

      def get_survey_responses(opts = {})
        Delighted::SurveyResponse.all(opts)
      end

      def get_metrics(opts = {})
        Delighted::Metrics.retrieve(opts)
      end

      def get_unsubscribed_list(opts = {})
        Delighted::Unsubscribe.all(opts)
      end

      def get_bounced_list(opts = {})
        Delighted::Bounce.all(opts)
      end

      private
        def properties_for_nps(user)
          {
            id:                    user.id,
            board:                 user.demo_id,
            organization:          user.organization_id,
            created_at:            user.created_at,
            board_type:            (user.demo.try(:is_paid) ? "Paid" : "Free"),
          }
        end

        def post_to_delighted?
          ENV['RACK_ENV'] == 'production' && !user.is_site_admin && !user.is_test_user
        end
    end
  end
end
