module Reporting 
  class ClientUsage
   
    def initialize demo, beg_date=3.months.ago, end_date =Date.today
      @user_activation = Reporting::Db::UserActivation.new(demo,beg_date, end_date)
      @tile_activity = Reporting::Db::TileActivity.new(demo,beg_date, end_date)
      @fields=init_report_fields
    end

   def run
     @fields[:activation][:total_eligible] = @user_activation.total_eligible
     @fields[:activation][:total_activated] = @user_activation.total_activated
     @fields[:activation][:newly_activated] = @user_activation.newly_activated
     @fields[:activation][:activation_pct] = @user_activation.activation_pct

     @fields[:tile_activity][:posted] = @tile_activity.tiles_posted
     @fields[:tile_activity][:available] = @tile_activity.tiles_available
     @fields[:tile_activity][:views] = @tile_activity.views
     @fields[:tile_activity][:completions] = @tile_activity.completions
     @fields[:tile_activity][:views_over_available] =@tile_activity.views_over_available
     @fields[:tile_activity][:completions_over_views] =@tile_activity.completions_over_views
     @fields
   end

   def init_report_fields
     {
       activation: {
         total_eligible: nil,
         total_activated: nil,
         newly_activated: nil, 
         activation_pct: nil,
       },

       tile_activity: {
         posted: nil,
         available: nil,
         views: nil,
         completions: nil,
         viewed_over_posted: nil,
         views_over_completed: nil,
       }

   end
  end
end
