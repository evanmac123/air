# frozen_string_literal: true

class Admin::GuestUserTileCompletionReportsController < AdminBaseController
  def show
    @demo = Demo.find(params[:demo_id])
    respond_to do |format|
      format.html
      format.csv { send_data generate_tile_completion_csv, filename: "guest_user_tile_completions_#{Date.today}.csv" }
    end
  end

  private
    def get_ids_from_params
      params.keys.map do |param|
        param.split("_").last if param.include?("generate_tile_")
      end.compact
    end

    def generate_tile_completion_csv
      attrs = %w{tile_id user_id answer_index free_form_response}
      ids = get_ids_from_params
      CSV.generate(headers: true) do |csv|
        csv << attrs
        @demo.tiles.where(id: ids).each do |tile|
          tile_completions = tile.tile_completions.where(user_type: "GuestUser")
          tile_completions.each { |tc| csv << attrs.map { |attr| tc.send(attr) } }
        end
      end
    end
end
