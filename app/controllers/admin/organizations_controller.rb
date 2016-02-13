require 'custom_responder'
class Admin::OrganizationsController < AdminBaseController
  include CustomResponder

  before_filter :find_organization, only: [:edit, :show, :update, :destroy]
  before_filter :parse_dates, only: [:metrics_recalc]

  def index
    @organizations = Organization.all
  end

  def show
  end

  def metrics
    @data = {}
  end

  def metrics_recalc
    @data = {}
    @data["active"] = Organization.active_during_period @sdate, @edate 
    @data["added"] = Organization.added_during_period @sdate, @edate
    @data["possible_churn"] = Organization.possible_churn_during_period @sdate, @edate
    @data["churned"] = Organization.churned_during_period @sdate, @edate
    render "metrics"
  end

  def new
    @organization = Organization.new
    new_or_edit @organization 
  end

  def edit
    new_or_edit @organization
  end

  def create 
    @organization = Organization.new(organization_params)
    update_or_create @organization, admin_organizations_path(@organization)
  end

  def update
    @organization.assign_attributes organization_params
    update_or_create @organization, admin_organizations_path(@organization)
  end

  private
  def parse_dates
   @sdate = Date.strptime(params[:sdate], "%Y-%m-%d")
   @edate = Date.strptime(params[:edate], "%Y-%m-%d")
  end
  def find_organization
    @organization = Organization.find(params[:id])
  end

  def organization_params
    params.require(:organization).permit(:churn_reason, :name, :num_employees, :sales_channel)
  end
end
