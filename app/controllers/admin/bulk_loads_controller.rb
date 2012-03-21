require 'csv'

class Admin::BulkLoadsController < AdminBaseController
  before_filter :find_demo_by_demo_id
  before_filter :find_available_characteristics

  def new
  end

  def create
    successful_creations = 0
    @errored_users = []

    CSV.parse(params[:bulk_user_data]).each do |row|
      name, email, claim_code, unique_id = extract_user_data_from_row(row)

      User.where(:email => email.downcase).destroy_all

      user = @demo.users.build(:name => name, :email => email, :claim_code => claim_code)
      

      if add_characteristics_from_extra_columns(user, row) && user.save
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

  def find_available_characteristics
    @generic_characteristics = Characteristic.generic
    @demo_specific_characteristics = Characteristic.in_demo(@demo)
  end

  def extra_column_characteristics
    return @extra_column_characteristics if @extra_column_characteristics
    @extra_column_characteristics = {}
    params[:extra_column].each do |column_index, characteristic_id|
      next unless characteristic_id.present?
      @extra_column_characteristics[column_index.to_i] = Characteristic.find(characteristic_id)
    end
    @extra_column_characteristics
  end

  def add_characteristics_from_extra_columns(user, row)
    return true if row.length < 5

    extra_column_characteristics.each do |column_index, characteristic|
      next unless row[column_index].present?

      if characteristic.allowed_values.include?(row[column_index])
        user.characteristics ||= {}
        user.characteristics[characteristic.id] = row[column_index]
      else
        # Can't do this with user.errors.add since it seems to ignore the
        # error on characteristics on save or valid?.
        user.errors.add(:characteristics, "bad value for #{characteristic.name}: #{row[column_index]}")
        return false
      end
    end

    true
  end
end
