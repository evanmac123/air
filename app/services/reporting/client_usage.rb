module Reporting 
  class ClientUsage

    def self.run demo, beg_date=3.months.ago, end_date =Date.today
      data = {
        demo_id: demo,
        beg_date: beg_date, 
        end_date: end_date, 
        activation:{}, 
        tile_activity:{}
      }

      if demo
        user_activation = Reporting::Db::UserActivation.new(demo,beg_date, end_date)
        tile_activity = Reporting::Db::TileActivity.new(demo,beg_date, end_date)

        data[:activation][:total_eligible] = user_activation.total_eligible
        data[:activation][:total_activated] = user_activation.total_activated
        data[:activation][:newly_activated] = user_activation.newly_activated
        data[:activation][:activation_pct] = user_activation.activation_pct

        data[:tile_activity][:posted] = tile_activity.posted
        data[:tile_activity][:available] = tile_activity.available
        data[:tile_activity][:views] = tile_activity.views
        data[:tile_activity][:completions] = tile_activity.completions
        data[:tile_activity][:views_over_available] =tile_activity.views_over_available
        data[:tile_activity][:completions_over_views] =tile_activity.completions_over_views
      end
      data
    end

  end
end
