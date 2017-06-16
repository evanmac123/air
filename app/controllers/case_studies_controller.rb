class CaseStudiesController < ApplicationController
  layout "marketing_site"

  def index
    @case_studies = CaseStudy.order_by_position
  end
end
