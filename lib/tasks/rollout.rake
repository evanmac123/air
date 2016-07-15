namespace :rollout do
  desc "Activates intro tooltip for first tile for 50% of users"
  task activate_first_tile_hint: :environment do
    $rollout.define_group(:first_tile_hint) do |user|
      !user.tile_completions.first.present?
    end

    $rollout.activate_percentage(:first_tile_hint, 50)
  end
end
