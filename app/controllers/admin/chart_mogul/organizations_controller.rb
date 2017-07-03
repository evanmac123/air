class Admin::ChartMogul::OrganizationsController < AdminBaseController
  def sync
    @organization = Organization.where(slug: params[:organization_id]).first

    chart_mogul_service = ChartMogulService::Sync.new(organization: @organization)

    chart_mogul_service.sync
    flash[:success] = "#{@organization.name} scheduled to sync with ChartMogul. It may take a few minutes to fully sync."

    redirect_to :back
  end

  def destroy
    @organization = Organization.where(slug: params[:id]).first

    chart_mogul_service = ChartMogulService::Remove.new(organization: @organization)

    if chart_mogul_service.remove_from_chart_mogul
      flash[:success] = "#{@organization.name} has been removed from Chart Mogul"
    else
      flash[:failure] = "#{@organization.name} could not be removed from Chart Mogul at this time. ChartMogul data has been cleaned for this org in Airbo. Please confirm the org is removed in ChartMogul, or remove manually from the ChartMogul UI."
    end

    chart_mogul_service.remove_chart_mogul_uuids

    redirect_to :back
  end
end
