# frozen_string_literal: true

class CaseStudiesController < ApplicationController
  layout "case_study"

  def index
    @case_studies = load_case_studies
  end

  def show
    @case_study = load_case_studies[params[:id]]
    raise ActionController::RoutingError.new("Not Found") unless @case_study
  end

  private
    def load_case_studies
      YAML.load(File.open("#{Rails.root}/config/case_studies.yml", "r"))
    end
end
