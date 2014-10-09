class AddShareSectionIntroSeenToUser < ActiveRecord::Migration
  def change
  	add_column :users, :share_section_intro_seen, :boolean
  end
end
