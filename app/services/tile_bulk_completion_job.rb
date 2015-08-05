class TileBulkCompletionJob
  def initialize(demo_id, tile_id, emails)
    @demo_id = demo_id
    @tile_id = tile_id
    @emails = emails
  end

  def perform
    completion_states = {}
    %w(completed unknown already_completed in_different_game).each {|bucket| completion_states[bucket.to_sym] = []}

    tile = Tile.find(@tile_id)

    @emails.each do |email|
      user = User.find_by_either_email(email)

      unless user
        completion_states[:unknown] << email
        next
      end

      unless user.demo_ids.include? @demo_id.to_i
        completion_states[:in_different_game] << email
        next
      end

      if Tile.satisfiable_to_user(user).include? tile
        tile_satisfy_for_user!(tile, user)
        completion_states[:completed] << email
      else
        completion_states[:already_completed] << email
      end

    end

    BulkCompleteMailer.delay_mail(:report, completion_states)
  end

  protected 

  def tile_satisfy_for_user!(tile, user)
    TileCompletion.create!(:tile_id => tile.id, :user => user)
    Act.create!(:user => user, :inherent_points => tile.bonus_points, :text => "")
  end
end
