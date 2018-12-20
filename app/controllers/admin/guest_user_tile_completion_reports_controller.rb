# frozen_string_literal: true

class Admin::GuestUserTileCompletionReportsController < AdminBaseController
  def show
    @demo = Demo.find(params[:demo_id])
    generate_tile_completion_csv if formats.include?(:csv)
    respond_to do |format|
      format.html
      format.csv { send_data @report, filename: "guest_user_tile_completions_#{Date.today}.csv" }
    end
  end

  private
    def generate_tile_completion_csv
      @report = {}
      binding.pry
    end
end
