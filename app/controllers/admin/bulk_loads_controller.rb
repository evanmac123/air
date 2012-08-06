require 'csv'

class Admin::BulkLoadsController < AdminBaseController
  before_filter :find_demo_by_demo_id
  before_filter :find_available_characteristics

  def new
  end

  def create
    successful_creations, @errored_users = BulkLoader.new(@demo, params[:bulk_user_data], params[:extra_column]).bulk_load!
    @success_message = "Successfully loaded #{successful_creations} users."

    render :action => :new
  end

  protected

  def set_claim_code(user, claim_code)
    if claim_code
      user.update_attribute(:claim_code, claim_code)
    else
      user.generate_simple_claim_code!
    end
  end

  def find_available_characteristics
    @dummy_characteristics = DummyCharacteristic.all
    @generic_characteristics = Characteristic.generic
    @demo_specific_characteristics = Characteristic.in_demo(@demo)
  end
end
