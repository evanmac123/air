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
      # Tries to load static text from S3 first and falls back on local data if that fails
      load_yaml_from_s3 || YAML.load(File.open("#{Rails.root}/config/case_studies.yml", "r"))
    end

    def get_adjacent_case_studies
      case_studies = load_case_studies
      index = case_studies.keys.index(params[:id])
      [index - 2, index - 1, ((index + 1) % case_studies.keys.length), ((index + 2) % case_studies.keys.length)].map do |index|
        case_studies[case_studies.keys[index]].merge("key" => case_studies.keys[index])
      end
    end

    def load_yaml_from_s3
      s3 = AWS::S3.new(access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"], region: ENV["AWS_REGION"])
      begin
        raw = s3.buckets["airbo-production"].objects["static/case_studies.yml"].read
        Psych.load(raw)
      rescue AWS::S3::Errors::NoSuchKey
        false
      end
    end
end
