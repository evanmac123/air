class AddMediaSourceFieldsToCustSucessKpi < ActiveRecord::Migration
  def change
    add_column :cust_success_kpis, :tiles_with_image_search, :integer, default: 0
    add_column :cust_success_kpis, :tiles_with_image_upload, :integer, default: 0
    add_column :cust_success_kpis, :tiles_with_video_upload, :integer, default: 0
  end
end
