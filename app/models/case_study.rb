class CaseStudy < ActiveRecord::Base
  has_attached_file :pdf
  validates_attachment :pdf, presence: true, content_type: { content_type: "application/pdf" }

  has_attached_file :logo, { thumb: "x100" }
  validates_attachment :logo, presence: true,
  content_type: { content_type: /\Aimage\/.*\z/ }

  validates :client_name, uniqueness: true, presence: true

  before_save :update_slug

  def self.order_by_position
    order(:position)
  end

  def update_slug
    self.slug = client_name.parameterize
  end

  def display_path
    if non_pdf_url.present?
      non_pdf_url
    else
      pdf.url
    end
  end
end
