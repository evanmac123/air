class AddSentAtToTilesDigests < ActiveRecord::Migration
  def up
    add_column :tiles_digests, :sent_at, :datetime

    TilesDigest.find_each do |digest|
      digest.sent_at = digest.created_at
      digest.save
    end
  end

  def down
    remove_column :tiles_digests, :sent_at
  end
end
