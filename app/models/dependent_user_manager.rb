class DependentUserManager
  def initialize primarary_user_id
   @primary_user = User.find(primarary_user_id)
  end

  def create(params)
    @primary_user.dependent_user.create params
  end
end
