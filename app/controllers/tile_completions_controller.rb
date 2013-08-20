class TileCompletionsController < ApplicationController
  def create
    tile = find_tile
    act = create_act(tile)
    create_tile_completion(tile)
    flash[:success] = reply(act)
    check_sample_tile_done
    redirect_to :back
  end

  protected

  def find_tile
    if completed_tile_is_sample_tile
      current_user.sample_tile
    else
      Tile.find(params[:tile_id])
    end
  end

  def create_tile_completion(tile)
    if completed_tile_is_sample_tile
      current_user.sample_tile_completed = true
      current_user.save!
    else
      TileCompletion.create!(:tile_id => tile.id, :user_id => current_user.id)
    end
  end

  def create_act(tile)
    Act.create(user: current_user, demo_id: current_user.demo_id, inherent_points: points(tile), text: tile.text_of_completion_act, creation_channel: 'web')  
  end

  def check_sample_tile_done
    return unless completed_tile_is_sample_tile
    set_talking_chicken_sample_tile_done(:multiple_choice)
  end

  def reply(act)
    ["That's right!", act.post_act_summary].join  
  end

  def points(tile)
    if completed_tile_is_sample_tile && current_user.sample_tile_completed
      0
    else
      tile.points
    end
  end

  def completed_tile_is_sample_tile
    params[:tile_id].to_s == '0'
  end
end
