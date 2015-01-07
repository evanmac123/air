class CopyCustomLogoUrlToLogo < ActiveRecord::Migration
  def up
    Demo.all.each do |demo|
      custom_logo = demo.custom_logo_url
      if custom_logo.present? && demo.logo_file_name.blank?
        demo.logo = URI.parse(custom_logo)
        demo.save!
      end
    end

    remove_column :demos, :custom_logo_url
  end

  def down
    add_column :demos, :custom_logo_url, :string

    Demo.all.each do |demo|
      if demo.logo_file_name.present?
        demo.custom_logo_url = demo.logo.url
        demo.save!
      end
    end
  end
end
