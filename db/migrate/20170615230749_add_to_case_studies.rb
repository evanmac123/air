class AddToCaseStudies < ActiveRecord::Migration
  def change
    add_column :case_studies, :non_pdf_url, :string
    add_column :case_studies, :quote, :text
    add_column :case_studies, :quote_cite, :text
    add_column :case_studies, :quote_cite_title, :text
    add_column :case_studies, :position, :integer, default: 0
  end
end
