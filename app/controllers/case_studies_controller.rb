# frozen_string_literal: true

class CaseStudiesController < ApplicationController
  layout "case_study"

  def index
    @case_studies = load_case_studies
  end

  def show
    raise ActionController::RoutingError.new("Not Found") unless @case_study = load_case_studies[params[:id]]
    @adjacent_case_studies = get_adjacent_case_studies
  end

  private
    def load_case_studies
      YAML.load(File.open("#{Rails.root}/config/case_studies.yml", "r"))
    end

    def get_adjacent_case_studies
      case_studies = load_case_studies
      index = case_studies.keys.index(params[:id])
      [index - 2, index - 1, ((index + 1) % case_studies.keys.length), ((index + 2) % case_studies.keys.length)].map do |index|
        case_studies[case_studies.keys[index]].merge("key" => case_studies.keys[index])
      end
    end
end
