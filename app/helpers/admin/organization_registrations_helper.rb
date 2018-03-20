# frozen_string_literal: true

module Admin::OrganizationRegistrationsHelper
  def org_registrations_default_board_id
    org_registrations_demos_to_select_from.where(name: "HR Bulletin Board").first.try(:id)
  end

  def org_registrations_demos_to_select_from
    Demo.select([:id, :name, :organization_id]).includes(:organization).order("organizations.name")
  end
end
