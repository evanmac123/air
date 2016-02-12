require 'custom_responder'
class Admin::BillingsController < AdminBaseController
  include CustomResponder

  before_filter :find_billing, only: [:edit, :show, :update, :destroy]
  before_filter :set_contract, only: [:new]

  def index
    @billings = Billing.all
  end

  def show
  end

  def new
    @billing = @contract.billings.build({organization_id: @contract.organization_id})
    new_or_edit @billing 
  end

  def edit
    new_or_edit @billing
  end

  def create 
    @billing = Billing.new(billing_params)
    update_or_create @billing, admin_billings_path(@billing)
  end

  def update
    @billing.assign_attributes billing_params
    update_or_create @billing, admin_billings_path(@billing)
  end

  private

  def find_billing
    @billing = Billing.find(params[:id])
  end

  def billing_params
    params.require(:billing).permit(:posted, :contract_id, :organization_id, :amount)
  end

  def set_contract
    if params[:contract_id]
      @contract = Contract.where(id:  params[:contract_id]).first
    else
      @contract = Contract.new
    end
  end

end
