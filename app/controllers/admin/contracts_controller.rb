require 'custom_responder'
class Admin::ContractsController < AdminBaseController
  before_filter :find_contract, except: [:new, :create, :index]
  before_filter :set_parent_org
  before_filter :set_organizations
  before_filter :set_related_contracts
  before_filter :build_new_contract, only:[:new]
  include CustomResponder

  def index
    @contracts = Contract.all
  end

  def new
    @relationship = @parent_org ? "Primary" : "Upgrade"
    new_or_edit @contract
  end

  def edit
    new_or_edit @contract
  end

  def update
    @contract.assign_parms(contract_params)
    update_or_create @contract, admin_contract_path(@contract)
  end

  def create
    @contract = Contract.new(contract_params)
    update_or_create @contract, admin_contracts_path
  end


  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def contract_params
      params.require(:contract).permit(:organization_id,
                                       :is_upgrade,
                                       :amt_booked, :arr, :date_booked, 
                                       :end_date, :estimate_type, :max_users, 
                                       :mrr, :name, :notes, 
                                       :plan, :rank, :start_date, :term)
    end

    def find_contract
      @contract = Contract.find(params[:id])
    end

    def set_organizations
      @organizations = Organization.all
    end

    def set_parent_org
      if params[:organization_id]
        @parent_org = Organization.where(id:  params[:organization_id]).first
      end
    end

    def set_related_contracts
      if params[:contract_id]
        @parent_contract = Contract.where(id:  params[:contract_id]).first
      end
    end

    def build_new_contract
      @contract = if @parent_org
                    @parent_org.contracts.build({name: @parent_org.name})
                  else
                    @parent_contract.upgrades.build({name: @parent_contract.name})
                  end
    end

end
