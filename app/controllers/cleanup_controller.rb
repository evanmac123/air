class CleanupController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :destroy

  def destroy
    if ENV["CYPRESS_CLEANUP"] && params[:key] == ENV["CYPRESS_CLEANUP"]
      tables = ActiveRecord::Base.connection.tables
      tables.delete 'schema_migrations'
      tables.each { |t| ActiveRecord::Base.connection.execute("TRUNCATE #{t} CASCADE") }
      Rails.application.load_seed if params[:seed]
      render text: 'Truncated tables and seeded'
    end
  end
end
