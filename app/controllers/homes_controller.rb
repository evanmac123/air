class HomesController < ApplicationController
  def show
    @demo  = Demo.find_by_company_name("Alpha")
    #@user  = @demo.users.build
    @users = @demo.try(:users).try(:top, 5) || []
  end
end
