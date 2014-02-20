class TilePreviewsController < ApplicationController
  skip_before_filter :authorize

  def show
    render text: 'hey'
  end
end
