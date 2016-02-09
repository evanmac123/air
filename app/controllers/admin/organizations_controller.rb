require 'custom_responder'
class Admin::OrganizationsController < AdminBaseController
  include CustomResponder

  before_filter :find_organization, only: [:edit, :update, :destroy]

  def index
    @organizations = Organization.all
  end

  def new
    @organization = Organization.new
    new_or_edit @organization 
  end

  def edit
    new_or_edit @organization
  end

  def update
    update_or_create @organization
  end

  private

  def find_organization
    @Organization = Organization.find(id)
  end

  def organization_params
    params.require(:organization).permit(:churn_reason, :churned, :name, :num_employees, :sales_channel)
  end
end
