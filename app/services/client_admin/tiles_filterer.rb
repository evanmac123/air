# frozen_string_literal: true

class ClientAdmin::TilesFilterer
  def self.call(demo:, params:)
    if params[:status] == Tile::PLAN
      ClientAdmin::PlanTilesFilterer.new(demo, params).call
    else
      ClientAdmin::ActiveTilesFilterer.new(demo, params).call
    end
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
    end

    def filter_date(query)
      query
    end

    def filter_campaign(query)
      campaign = params[:campaign]
      if campaign == "unassigned"
        query.where(campaign_id: nil)
      elsif campaign.to_i > 0
        query.where(campaign_id: campaign)
      else
        query
      end
    end
end
