class Admin::UserCharacteristicsController < AdminBaseController
  def update
    user = User.find_by_slug(params[:user_id])

    # So stupid that this is still the simplest way to do this...but
    # Hash#select and the like return a list of two-element lists rather than 
    # a Hash, for doubtless the best of reasons.

    unblank_characteristics = params[:characteristic].select{|k,v| v.present?}
    normalized_characteristics = unblank_characteristics.map{|k,v| [k.to_i, v]}
    normalized_characteristics = Hash[*normalized_characteristics.flatten]

    user.update_attributes(:characteristics => normalized_characteristics)
    flash[:success] = "Characteristics for #{user.name} updated"

    redirect_to :back
  end
end
