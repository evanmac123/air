class ConvertToFullUser
  attr_reader :converted_user

  def initialize(params = {})
    @pre_user = params[:pre_user]
    @name = params[:name]
    @email = params[:email]
    @password = params[:password]
    @location_name = params[:location_name]
    @converting_from_guest = params[:converting_from_guest]
  end

  def create_client_admin_with_board! demo
    @converted_user = User.new(
      name: @name,
      email: @email,
      accepted_invitation_at: Time.now,
    )
    @converted_user.creating_board = true
    @converted_user.is_client_admin = true
    @converted_user.password = @converted_user.password_confirmation = @password
    @converted_user.cancel_account_token = @converted_user.generate_cancel_account_token(@converted_user)

    if @pre_user && @pre_user.is_guest?
      @converted_user.original_guest_user = @pre_user
      @converted_user.mixpanel_distinct_id = @pre_user.mixpanel_distinct_id
    end

    if @converted_user.save
      if @pre_user && @pre_user.is_guest?
        @pre_user.converted_user = @converted_user
        @pre_user.save!

        @converted_user.save!
      end
      @converted_user.add_board(demo.id, true)
      @converted_user.reload
      @converted_user.send_conversion_email
      @converted_user
    else
      nil
    end
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
      @pre_user.tile_viewings.update_all(user_id: @converted_user.id, user_type: 'User')
      @pre_user.tile_completions.update_all(user_id: @converted_user.id, user_type: 'User')
      @pre_user.acts.update_all(user_id: @converted_user.id, user_type: 'User')
      @pre_user.user_in_raffle_infos.update_all(user_id: @converted_user.id, user_type: 'User')

      @converted_user.send_conversion_email
    end
  end

  def set_common_data_for_user
    @converted_user.password = @converted_user.password_confirmation = @password
    @converted_user.original_guest_user = @pre_user if @converting_from_guest
    @converted_user.cancel_account_token = @pre_user.generate_cancel_account_token(@converted_user)
    @converted_user.last_acted_at = @pre_user.last_acted_at
    @converted_user.location_id = find_location @location_name
    @converted_user.converting_from_guest = @converting_from_guest
    @converted_user.must_have_location = true if @location_name.present?

    if @pre_user && @pre_user.is_potential_user?
      @converted_user.primary_user = @pre_user.primary_user
    end
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
