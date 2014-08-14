class TileBoardDigestDecorator < TileDigestDecorator
  def email_site_link
    h.email_site_link(context[:user], 
                      context[:demo], 
                      context[:is_preview] ||= false, 
                      context[:email_type])
  end
end
