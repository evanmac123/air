# frozen_string_literal: true

class ClientAdmin::TilesFilterer
  def self.call(demo:, params:)
    ClientAdmin::TilesFilterer.new(demo, params).call
  end

  attr_reader :demo, :params

  def initialize(demo, params)
    @demo = demo
    @params = params
  end

  def call
    query = demo.tiles.where(status: params[:status])
    query = filter_date(query)
    query = filter_campaign(query)

    query.order(sort_query).page(params[:page]).per(16)
  end

  private

    def sort_query
      if params[:sort] == "plan_date"
        "plan_date IS NULL, plan_date DESC"
      else
        "position DESC"
      end
    end

    def filter_date(query)
      month = params[:month]
      if month == "unplanned"
        query.where(plan_date: nil)
      elsif month.present?
        query.where("extract(MONTH from plan_date) = ?", month)
      else
        query
      end
    end

    def filter_campaign(query)
      campaign = params[:campaign]
      if campaign == "unassigned"
        query.includes(:campaign_tiles).where(campaign_tiles: { tile_id: nil })
      elsif campaign.present?
        query.joins(:campaigns).where(campaigns: { id: campaign })
      else
        query
      end
    end
end
