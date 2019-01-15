# frozen_string_literal: true

class User::AccountRequestService
  attr_reader :name, :email, :phone_number, :company_name, :created_at, :error_message

  def initialize(params)
    @name = params[:name]
    @email = params[:email]
    @phone_number = params[:phone_number]
    @company_name = params[:company_name]
    @created_at = DateTime.now.strftime("%m/%d/%Y")
    @error_message
  end

  def send_request
    if valid_request?
      params = self.as_json
      AccountRequestNotifier.notify_customer_success(params).deliver_later
    else
      generate_error_message
      false
    end
  end

  def valid_request?
    if @name && (@email && (@email =~ /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/)) && @phone_number && @company_name
      sanitize_phone_number
      sanitize_organization_name
      true
    else
      false
    end
  end

  def as_json
    {
      name: @name,
      email: @email,
      phone_number: @phone_number,
      company_name: @company_name,
      created_at: @created_at,
    }.to_json
  end

  def generate_error_message
    @error_message = [:name, :email, :phone_number, :company_name].reduce("") do |result, method|
      result += "#{method.to_s.gsub('_', ' ').capitalize} can't be blank; " unless self.send(method)
      if method == :email
        result += "Unrecognized email address format; " unless self.send(method) =~ /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
      end
      result
    end
  end

  private
    def sanitize_phone_number
      @phone_number = "+1#{@phone_number.gsub(/\D/, "")}"
    end

    def sanitize_organization_name
      @company_name = @company_name.split.map(&:capitalize).join(" ")
    end
end
