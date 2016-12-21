module ActsHelper
  def set_modals_and_intros
    #FIXME this instance var is getting set 3 times
    @display_get_started_lightbox = current_user.display_get_started_lightbox
    @display_get_started_lightbox = false if params[:public_slug].present?

    # This is handy for debugging the lightbox or working on its styles
    @display_get_started_lightbox ||= params[:display_get_started_lightbox]



    if @display_get_started_lightbox
      @get_started_lightbox_message = persistent_message_or_default(current_user)
      current_user.get_started_lightbox_displayed = true
    end

    @display_activity_page_admin_guide = display_admin_guide?

    if @display_activity_page_admin_guide
      current_user.displayed_activity_page_admin_guide = true
    end

    if @display_get_started_lightbox == false
      @display_first_tile_hint =  current_user.intros.display_first_tile_hint?
    end

    @use_persistent_message = true

    current_user.save
  end

  def display_admin_guide?
    current_user.is_client_admin && current_user.displayed_activity_page_admin_guide
  end
end
