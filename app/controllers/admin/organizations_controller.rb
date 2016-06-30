require 'custom_responder'
class Admin::OrganizationsController < AdminBaseController
  include CustomResponder

  before_filter :find_organization, only: [:edit, :show, :update, :destroy]
  before_filter :parse_dates, only: [:metrics_recalc, :metrics, :kpis]

  def index
    @organizations = Organization.all
  end

  def show
  end

  def metrics
    @kpi =if @sdate && @edate 
            Metrics.by_start_and_end @sdate,@edate
          else
            @sdate, @edate = Metrics.default_date_range
            Metrics.current_week
          end
    respond_to do |format| 
      format.html
      format.csv do 
        data = FinancialsReporterService.to_csv @sdate, @edate
        send_data data, filename: "kpi-#{@sdate}-#{@edate}.csv" 
      end 
    end
  end


  def kpis
    @demos = Demo.paid
    @data = Reporting::ClientUsage.run(params[:demo_id], @sdate, @edate)

    respond_to do |format| 
      format.html
      format.csv do 
        data = FinancialsReporterService.to_csv @sdate, @edate
        send_data data, filename: "kpi-#{@sdate}-#{@edate}.csv" 
      end 
    end
  end

  def metrics_recalc
    @kpi = Metrics.by_start_and_end @sdate,@edate
    render :metrics
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
    @sdate = params[:sdate].present? ? Date.strptime(params[:sdate], "%Y-%m-%d") : nil
    @edate =  params[:edate].present? ? Date.strptime(params[:edate], "%Y-%m-%d") : nil
  end
  def find_organization
    @organization = Organization.find(params[:id])
  end

  def organization_params
    params.require(:organization).permit(:churn_reason, :name, :num_employees, :sales_channel)
  end
end
