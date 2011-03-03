require 'csv'

# TODO: Either remove this controller, or go back and do it properly,
# including tests. Right now it just has to work once.

class BulkLoadsController < ApplicationController
  before_filter :find_demo

  def new
  end

  def create
    successful_creations = 0
    @errored_users = []

    CSV.parse(params[:bulk_user_data]).each do |row|
      user = @demo.users.build(:name => row[0], :email => row[1])

      if user.save
        user.generate_simple_claim_code!
        successful_creations += 1
      else
        @errored_users << user
      end
    end

    @success_message = "Successfully loaded #{successful_creations} users."

    render :action => :new
  end

  protected

  def find_demo
    @demo = Demo.find(params[:demo_id])
  end
end
