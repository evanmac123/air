require 'csv'

class Admin::BulkLoadsController < AdminBaseController
  before_filter :find_demo_by_demo_id

  def new
  end

  def create
    successful_creations = 0
    @errored_users = []

    CSV.parse(params[:bulk_user_data]).each do |row|
      name, email, claim_code, unique_id = extract_user_data_from_row(row)

      User.where(:email => email.downcase).destroy_all

      user = @demo.users.build(:name => name, :email => email, :claim_code => claim_code)

      if user.save
        user.update_attributes(:sms_slug => unique_id)
        successful_creations += 1
      else
        @errored_users << user
      end
    end

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

  def extract_user_data_from_row(row)
    name = row[0].to_s
    email = row[1].to_s
    claim_code = row[2].to_s if row[2]
    unique_id = row[3].to_s if row[3]

    [name, email, claim_code, unique_id]
  end
end
