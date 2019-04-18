# frozen_string_literal: true

class Api::V1::RibbonTagsController < Api::ApiController
  before_action :verify_origin

  def index
    render json: current_user.demo.ribbon_tags
  end

  def create
    ribbon_tag = current_user.demo.ribbon_tags.new(ribbon_tag_params)

    if ribbon_tag.save
      ribbon_tag.schedule_mixpanel_ping("RibbonTag - Created")
      render json: ribbon_tag
    else
      render json: ribbon_tag.errors
    end
  end

  def update
    ribbon_tag = current_user.demo.ribbon_tags.find(params[:id])

    if ribbon_tag.update_attributes(ribbon_tag_params)
      ribbon_tag.schedule_mixpanel_ping("RibbonTag - Updated")
      render json: ribbon_tag
    else
      render json: ribbon_tag.errors
    end
  end

  def destroy
    ribbon_tag = RibbonTag.find(params[:id])
    render json: ribbon_tag.destroy
  end

  private
    def ribbon_tag_params
      params.require(:ribbon_tag).permit(:name, :color)
    end
end
