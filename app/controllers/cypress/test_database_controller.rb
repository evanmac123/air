# frozen_string_literal: true

class Cypress::TestDatabaseController < ApplicationController
  before_action :verify_cypress_key
  skip_before_action :verify_authenticity_token

  def create
    response = { status: "success", code: 200 }
    factory_attrs.each_with_index do |attrs, i|
      model = attrs.delete("model")
      factory_created = eval(model.capitalize).create!(attrs)
      response["#{model}-#{i}"] = factory_created
    end
    render json: response
  end

  def destroy
    tables = ActiveRecord::Base.connection.tables
    tables.delete "schema_migrations"
    tables.each { |t| ActiveRecord::Base.connection.execute("TRUNCATE #{t} CASCADE") }
    Rails.application.load_seed if params[:seed]
    render json: { status: "success", code: 200, message: "Tables successfully truncated" }
  end

  private
    def verify_cypress_key
      unless ENV["CYPRESS_CLEANUP"] && params[:key] == ENV["CYPRESS_CLEANUP"]
        render json: { status: "error", code: 999, message: "Invalid authentication token" }
      end
    end

    def factory_attrs
      params.require(:test_database).permit!["_json"]
    end
end
