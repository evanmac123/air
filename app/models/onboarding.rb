class Onboarding < ActiveRecord::Base
  belongs_to :organization
  belongs_to :board, class_name: Demo, foreign_key: :demo_id

  has_many :user_onboardings, dependent: :destroy, autosave: true do

    def first_or_build_for_user(user)
      where(user_id: user.id).first || build({user_id: user.id})
    end
  end


  private

  def purge
     user_onboardings.delete_all
     board.delete
     organization.delete
     board.users.delete_all
     self.destroy
  end

end
