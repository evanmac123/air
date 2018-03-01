# frozen_string_literal: true

class OrganizationRegistration
  include ActiveModel::Model

  attr_accessor(
    :organization_name,
    :user_name,
    :user_email,
    :board_name,
    :board_template_id
  )

  validate :validate_children

  def save
    if valid?
      ActiveRecord::Base.transaction do
        organization.save!
        board.save!
        user.save!
      end
    else
      false
    end
  end

  def organization
    @organization ||= Organization.new(
      name: organization_name,
      email: user_email
    )
  end

  def board
    @board ||= organization.demos.build(
      name: get_board_name,
      guest_user_conversion_modal: false
    )
  end

  def user
    @user ||= board.users.build(
      name: user_name,
      email: user_email,
      is_client_admin: true
    )
  end

  private

    def get_board_name
      if board_name.present?
        board_name
      else
        organization_name
      end
    end

    def validate_children
      if organization.invalid?
        promote_errors(organization.errors)
      end

      if board.invalid?
        promote_errors(board.errors)
      end

      if user.invalid?
        promote_errors(user.errors)
      end
    end

    def promote_errors(child_errors)
      child_errors.each do |attribute, message|
        errors.add(attribute, message)
      end
    end
end
