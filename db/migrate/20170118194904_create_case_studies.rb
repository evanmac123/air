class CreateCaseStudies < ActiveRecord::Migration
  def change
    create_table :case_studies do |t|
      t.string :client_name
      t.text :description
      t.string :slug
      t.attachment :cover_image
      t.attachment :logo
      t.attachment :pdf

      t.timestamps
    end
  end
end
