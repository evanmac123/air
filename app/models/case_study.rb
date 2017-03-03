class CaseStudy < ActiveRecord::Base
  has_attached_file :pdf
  validates_attachment :pdf, presence: true, content_type: { content_type: "application/pdf" }

  has_attached_file :logo, { thumb: "x100" }
  validates_attachment :logo, presence: true,
  content_type: { content_type: /\Aimage\/.*\z/ }

  has_attached_file :cover_image, { display: "250x375x" }
  validates_attachment :cover_image, presence: true,
  content_type: { content_type: /\Aimage\/.*\z/ }

  validates :client_name, uniqueness: true, presence: true

  before_save :update_slug

  def update_slug
    self.slug = client_name.parameterize
  end

  def to_param
    [id, client_name.parameterize].join("-")
  end
end
