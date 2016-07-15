namespace :rollout do
  desc "Activates intro tooltip for first tile for 50% of users"
  task activate_first_tile_hint: :environment do
    $rollout.define_group(:new_users) do |user|
      new_user = !user.tile_completions.first.present?
      # we need half of new users
      half = user.id % 2 == 0
      new_user && half
    end

    $rollout.activate_group(:first_tile_hint, :new_users)
  end
end
