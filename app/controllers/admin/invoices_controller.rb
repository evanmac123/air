class Admin::InvoicesController < AdminBaseController
  def create
    invoice = Invoice.new(invoice_params)

    if invoice.save
      ChartMogulService::Sync.new(organization: invoice.organization).sync
      flash[:success] = "Invoice created. ChartMogul sync in progress. It may take a few minutes to complete."
    else
      flash[:failure] = invoice.errors.full_messages.to_sentence
    end

    redirect_to admin_organization_path(params[:organization_id])
  end

  def destroy
    @invoice = Invoice.find(params[:id])

    if @invoice.chart_mogul_uuid
      remove_invoice_from_chart_mogul_and_destroy
    else
      @invoice.destroy
      flash[:success] = "Invoice deleted."
    end

    redirect_to :back
  end

  private

    def invoice_params
      params.require(:invoice).permit(:subscription_id, :amount_in_cents, :service_period_start, :service_period_end)
    end

    def remove_invoice_from_chart_mogul_and_destroy
      if ChartMogulService::Invoice.new(invoice: @invoice).remove_invoice
        @invoice.destroy
        flash[:success] = "Invoice deleted."
      else
        flash[:failure] = "Invoice could not be removed from ChartMogul. Please try again."
      end
    end
end
