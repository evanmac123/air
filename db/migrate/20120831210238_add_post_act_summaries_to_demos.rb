class AddPostActSummariesToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :use_post_act_summaries, :boolean, :default => true
    execute "UPDATE demos SET use_post_act_summaries = true"
  end
end
