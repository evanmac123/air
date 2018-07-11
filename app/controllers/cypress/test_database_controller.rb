# frozen_string_literal: true

class Cypress::TestDatabaseController < ApplicationController
  before_action :verify_cypress_key
  skip_before_action :verify_authenticity_token

  def create
    response = { status: "success", code: 200 }
    factory_attrs.each_with_index do |attrs, i|
      model = attrs.delete("model")
      actions = attrs.delete("addActions")
      factory_created = eval(model.capitalize).create!(sanitize_attrs(attrs))
      perform_addtional(actions, factory_created) if actions
      response["#{model}-#{i}"] = factory_created.as_json(root: false)
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

    def sanitize_attrs(attrs)
      if associations = attrs.delete("associations")
        associations.keys.reduce(attrs) { |result, assoc_name| result.merge("#{assoc_name}_id" => associations[assoc_name]) }
      else
        attrs
      end
    end

    def perform_addtional(actions, factory_created)
      actions.each do |action|
        case action
        when 'login'
          sign_in(factory_created)
        end
      end
    end
end
