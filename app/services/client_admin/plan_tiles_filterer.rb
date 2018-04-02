# frozen_string_literal: true

class ClientAdmin::PlanTilesFilterer < ClientAdmin::TilesFilterer
  private

    def sort_query
      if params[:sort] == "month"
        "plan_date IS NULL, plan_date ASC"
      else
        "position DESC"
      end
    end

    def filter_date(query)
      month = params[:month]
      if month == "unplanned"
        query.where(plan_date: nil)
      elsif month.to_i > 0
        query.where("extract(MONTH from plan_date) = ?", month)
      else
        query
      end
    end
end
