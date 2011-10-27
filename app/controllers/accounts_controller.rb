class AccountsController < ApplicationController
  def update
    current_user.attributes = params[:user]
    current_user.save!
    flash[:success] = "Your account settings have been updated."

    current_user.previous_changes.each do |field_name, changes|
      next if field_name == 'updated_at' || field_name == 'created_at'
      flash["mp_track_#{field_name}"] = ["changed #{field_name.humanize.downcase}", {:to => changes.last}]
    end

    redirect_to current_user
  end
end
