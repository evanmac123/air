require 'custom_responder'
class Admin::ContractsController < AdminBaseController
  before_filter :find_contract, except: [:new, :index]
  include CustomResponder

  def index
    @contracts = Contract.all
  end

  def new
    @contract = Contract.new
    new_or_edit @contract
  end

  def edit
    new_or_edit @contract
  end

  def update
    update_or_create @contract
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def contract_params
      params.require(:contract).permit(:amt_booked, :arr, :date_booked, :end_date, :estimate_type, :max_users, :mrr, :name, :notes, :organization, :plan, :rank, :start_date, :term)
    end

    def find_contract
      @contract = Contract.find(params[:id])
    end 
end
