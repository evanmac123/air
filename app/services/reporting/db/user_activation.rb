require 'reporting/db/by_board'
module Reporting
  module Db
    class UserActivation < ByBoard

      def eligibles
        qry = query_builder(memberships, "users.created_at", "users.created_at", ["users.created_at < ?", end_date])
        memberships.find_by_sql(wrapper_sql(qry))
      end

      def activations 
        qry = query_builder(memberships, "users.accepted_invitation_at", "users.id", ["users.accepted_invitation_at is not null and users.accepted_invitation_at <= ?", end_date])
        memberships.find_by_sql(wrapper_sql(qry))
      end


      private


      def memberships
        User.joins(:board_memberships).where("board_memberships.demo_id" => @demo_id)
      end

    end
  end
end
