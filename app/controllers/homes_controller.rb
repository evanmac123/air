class HomesController < ApplicationController
  def show
    @demo    = Demo.find_by_company_name("Alpha")
    @user  = @demo.users.build
    @users = @demo.users.top(5)
  end
end
