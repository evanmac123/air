# frozen_string_literal: true

class Cypress::TestDatabaseController < ApplicationController
  before_action :verify_cypress_key
  skip_before_action :verify_authenticity_token

  def create
    @built_associations = {}
    response = { status: "success", code: 200 }
    factory_attrs.each_with_index do |attrs, i|
      if attrs[:model]
        model = attrs[:model]
        factory_created = build_factory(attrs)
        response["#{model}-#{i}"] = factory_created.as_json(root: false)
      end
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

    def find_attrs_for(assoc_name)
      factory_attrs.each do |factory_attr|
        return factory_attr if factory_attr[:builtAssoc] == assoc_name
      end
      assoc_name
    end

    def sanitize_attrs(attrs)
      if associations = attrs.delete("associations")
        associations.keys.reduce(attrs) do |result, assoc_name|
          association = eval("#{assoc_name.capitalize}.find_by(id: #{associations[assoc_name].to_i})") ||
                       @built_associations[associations[assoc_name]] ||
                       build_factory(find_attrs_for(associations[assoc_name]))
          result.merge("#{assoc_name}" => association)
        end
      else
        attrs
      end
    end

    def perform_addtional(actions, factory_created)
      actions.each do |action|
        case action
        when "login"
          sign_in(factory_created)
        end
      end
    end

    def build_factory(attrs)
      model = attrs.delete(:model)
      actions = attrs.delete(:addActions)
      association_id = attrs.delete(:builtAssoc)
      factory_created = @built_associations[association_id] || eval(model.capitalize).create!(sanitize_attrs(attrs))
      @built_associations[association_id] = factory_created if association_id
      perform_addtional(actions, factory_created) if actions
      factory_created
    end
end
