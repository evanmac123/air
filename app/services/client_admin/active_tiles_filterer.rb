# frozen_string_literal: true

class ClientAdmin::ActiveTilesFilterer < ClientAdmin::TilesFilterer
  private

    def sort_query
      if params[:sort] == "month"
        "activated_at IS NULL, activated_at DESC"
      else
        "position DESC"
      end
    end

    def filter_date(query)
      month = params[:month]
      year = params[:year]

      if month.to_i > 0
        query = query.where("extract(MONTH from activated_at) = ?", month)
      end

      if year.to_i > 0
        query = query.where("extract(YEAR from activated_at) = ?", year)
      end

      query
    end
end
