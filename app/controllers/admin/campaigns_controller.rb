class Admin::CampaignsController < AdminBaseController
  def new
    render json: { success: true,
                   html: render_to_string(
                     layout: false,
                     template: 'admin/campaigns/_campaign_form',
                     locals: { campaign: Campaign.new, demos: Demo.airbo }
                   )
                 }
  end

  def show
    render json: { success: true,
                   html: render_to_string(
                     layout: false,
                     template: 'admin/campaigns/_campaign_form',
                     locals: { campaign: Campaign.find(params[:id]), demos: Demo.airbo }
                   )
                 }
  end

  def index
    @campaigns = Campaign.scoped
  end

  def create
    @campaign = Campaign.new(campaign_params)

    @campaign.save ? render_success : render_error
  end

  def update
    @campaign = Campaign.find(params[:id])

    @campaign.update_attributes(campaign_params) ? render_success : render_error
  end

  private
    def campaign_params
      params.require(:campaign).permit(:name, :description, :demo_id, :cover_image, :tag_list)
    end

    def render_success
      render json:
        {
          success: true,
          campaign: @campaign.attributes.merge(cover_image_url: @campaign.cover_image.url)
        }
    end

    def render_error
      render json:
        {
          success: false,
          errors:  @campaign.errors.full_messages.join(", ")
        }
    end
end
