# frozen_string_literal: true

class Api::ClientAdmin::PopulationSegmentsController < Api::ClientAdminBaseController
  def create
    @population_segment = current_board.population_segments.new(population_segment_params)

    if @population_segment.save
      render json: @population_segment
    else
      render json: { errors: @population_segment.errors.messages }, status: 400
    end
  end

  def update
    @population_segment = current_board.population_segments.find(params[:id])

    if @population_segment.update_attributes(population_segment_params)
      render json: @population_segment
    else
      render json: { errors: @population_segment.errors.messages }, status: 400
    end
  end

  def destroy
    @population_segment = current_board.population_segments.find(params[:id])

    @population_segment.destroy
    head 204
  end

  private

    def population_segment_params
      params.require(:population_segment).permit(:name)
    end
end
