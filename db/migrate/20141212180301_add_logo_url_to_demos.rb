class AddLogoUrlToDemos < ActiveRecord::Migration
  unless const_defined?("Skin")
    class Skin < ActiveRecord::Base
    end
  end

  def up
    add_column :demos, :custom_logo_url, :string
    Demo.reset_column_information

    Skin.all.each do |skin|
      demo = Demo.where(id: skin.demo_id).first
      next unless demo

      demo.custom_logo_url = skin.logo_url
      demo.save!
    end

    drop_table :skins
  end

  def down
    create_table :skins do |t|
      t.string :logo_url
      t.string :alt_logo_text
      t.belongs_to :demo
    end
    Skin.reset_column_information

    Demo.where("custom_logo_url IS NOT NULL").each do |demo|
      Skin.create!(demo_id: demo.id, logo_url: demo.custom_logo_url)
    end

    remove_column :demos, :custom_logo_url
  end
end
