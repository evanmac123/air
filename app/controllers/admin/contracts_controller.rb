require 'custom_responder'
require 'file_upload_wrapper'
require 'contract_from_data_row'

class Admin::ContractsController < AdminBaseController
  before_filter :find_contract, except: [:new, :create, :index, :import]
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
    @contract.assign_attributes(contract_params)
    update_or_create @contract, admin_contract_path(@contract)
  end

  def create
    @contract = Contract.new(contract_params)
    update_or_create @contract, admin_contracts_path
  end

  def destroy
    delete_resource @contract, admin_contracts_path
  end

  def import
    importer = ContractImporter.new(FileUploadWrapper.new(params[:file]))
    heads = importer.header
    org = nil
    importer.rows.each do |row| 
      org = Organization.where(name: row["Company"]).first_or_initialize
      org.num_employees = 1
      org.sales_channel = "Direct"
      org.save

      contract = org.contracts.build
      data = heads.reject{|h| h=="Company"}

      data.each do|head| 
        contract[field_mapping[head]]=row[head]
      end

      contract.name = org.name + (org.contracts.count +1).to_s
      contract.save
    end
    redirect_to admin_contracts_path
  end

  private

  # Use this method to whitelist the permissible parameters. Example:
  # params.require(:person).permit(:name, :age)
  # Also, you can specialize this method with per-user checking of permissible attributes.
  def contract_params
    params.require(:contract).permit(:organization_id, :parent_contract_id, :plan,
                                     :end_date,:start_date, 
                                     :arr, :mrr, :name,  
                                     :amt_booked, :date_booked, 
                                     :is_actual, :max_users,
                                     :term, :notes)
  end

  def show_mrr?
    @contract.new_record? || @contract.mrr.present?
  end

  def show_arr?
    @contract.new_record? || @contract.mrr.present?
  end

  def calced_rr
    show_mrr? ? "Annual" : "Monthly"
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
                  @parent_contract.upgrades.build({name: @parent_contract.name, organization_id: @parent_contract.organization_id})
                end
  end

  helper_method :show_mrr?, :calced_rr

  def field_mapping
    @mapping ||= {
      "Company"=>"name",
      "Start Date"=>"start_date",
      "End Date"=>"end_date",
      "Amount Booked"=>"amt_booked",
      "Date Booked"=>"date_booked",
      "Plan"=>"plan",
      "MRR"=>"marr",
      "ARR"=>"arr",
      "Max Users"=>"max_users"
    }
  end
end
