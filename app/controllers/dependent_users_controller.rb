class DependentUsersController < ApplicationController

def create
  DependentUserManager.create(params)
end

end
