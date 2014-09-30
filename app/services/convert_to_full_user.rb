class ConvertToFullUser
  def initialize(params = {})
    @pre_user = params[:pre_user]
    @name = params[:name]
    @email = params[:email]
    @password = params[:password]
    @location_name = params[:location_name]
    @converting_from_guest = params[:converting_from_guest]
  end

  def convert!
    @converted_user = User.find_by_email(@email)
    if @converted_user && @converted_user.unclaimed?
      set_basic_data_for_existing_user
    else
      set_basic_data_for_new_user
    end
    set_common_data_for_user

    if @converted_user.save
      @converted_user.add_board(@pre_user.demo_id, true)
      copy_data_from_guest
      @converted_user
    else
      copy_errors_to_pre_user
      nil
    end
  end

  protected

  def copy_errors_to_pre_user
    @converted_user.errors.messages.each do |field, error_messages|
      # the #uniq gets rid of duplicate password errors
      @pre_user.errors.set(field, error_messages.uniq) 
    end
  end

  def copy_data_from_guest
    if @converting_from_guest
      @pre_user.tile_completions.each do |tile_completion| 
        tile_completion.user = @converted_user 
        tile_completion.save!
      end
      @pre_user.acts.each do |act| 
        act.user = @converted_user 
        act.save!
      end
      UserInRaffleInfo.where(user_id: @pre_user.id, user_type: "GuestUser").each do |u_info|
        u_info.update_attributes(user_id: @converted_user.id, user_type: "User")
      end
      @converted_user.send_conversion_email
    end
  end

  def set_common_data_for_user
    @converted_user.password = @converted_user.password_confirmation = @password
    @converted_user.original_guest_user = @pre_user if @converting_from_guest
    @converted_user.cancel_account_token = @pre_user.generate_cancel_account_token(@converted_user)
    @converted_user.last_acted_at = @pre_user.last_acted_at
    @converted_user.voteup_intro_seen = @pre_user.voteup_intro_seen
    @converted_user.share_link_intro_seen = @pre_user.share_link_intro_seen
    @converted_user.location_id = find_location @location_name
    @converted_user.converting_from_guest = @converting_from_guest
    @converted_user.must_have_location = true if @location_name.present?
  end

  def set_basic_data_for_new_user
    @converted_user = User.new(
      name: @name, 
      email: @email, 
      points: @pre_user.points, 
      tickets: @pre_user.tickets, 
      get_started_lightbox_displayed: @pre_user.get_started_lightbox_displayed, 
      accepted_invitation_at: Time.now, 
      characteristics: {}
    )
  end

  def set_basic_data_for_existing_user
    @converted_user.name = @name
    @converted_user.email = @email
    @converted_user.points = @pre_user.points
    @converted_user.tickets = @pre_user.tickets
    @converted_user.get_started_lightbox_displayed = @pre_user.get_started_lightbox_displayed
    @converted_user.accepted_invitation_at = Time.now
    @converted_user.characteristics = {}
  end

  def find_location location_name
    if location_name.present? 
      Location.where(name: location_name)
              .where(demo_id: @pre_user.demo_id)
              .pluck(:id).first
    else
      nil
    end
  end
end