class ExplorePolicy < ApplicationPolicy
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def show?
    binding.pry
    user.admin? or not post.published?
  end
end
