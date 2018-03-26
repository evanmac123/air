# frozen_string_literal: true

class ClientAdmin::ActiveTilesFilterer < ClientAdmin::TilesFilterer
  private

    def sort_query
      if params[:sort] == "activated_at"
        "activated_at IS NULL, activated_at DESC"
      else
        "position DESC"
      end
    end

    def filter_date(query)
      month = params[:month]
      if month == "unplanned"
        query.where(activated_at: nil)
      elsif month.present?
        query.where("extract(MONTH from activated_at) = ?", month)
      else
        query
      end
    end
end
