class Admin::ChannelsController < AdminBaseController
  def new
    render json: { success: true,
                   html: render_to_string(
                     layout: false,
                     template: 'admin/channels/_channel_form',
                     locals: { channel: Channel.new }
                   )
                 }
  end

  def show
    render json: { success: true,
                   html: render_to_string(
                     layout: false,
                     template: 'admin/channels/_channel_form',
                     locals: { channel: Channel.find_by_slug(params[:id]) }
                   )
                 }
  end

  def index
    @channels = Channel.scoped
  end

  def create
    @channel = Channel.new(channel_params)

    @channel.save ? render_success : render_error
  end

  def update
    @channel = Channel.find_by_slug(params[:id])

    @channel.update_attributes(channel_params) ? render_success : render_error
  end

  private
    def channel_params
      params.require(:channel).permit(:name, :image, :active, :image_header)
    end

    def render_success
      render json:
        {
          success: true,
          channel: @channel.attributes.merge(image_url: @channel.image.url(:explore))
        }
    end

    def render_error
      render json:
        {
          success: false,
          errors:  @channel.errors.full_messages.join(", ")
        }
    end
end
