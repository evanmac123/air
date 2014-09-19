class LocationsController < ApplicationController
  prepend_before_filter :allow_guest_user

  def index
    find_search_results
    render_search_results_as_json
  end

  protected

  def find_search_results
    normalized_term = params[:term].downcase.strip.gsub(/\s+/, ' ')
    @search_results = Location.name_ilike(normalized_term).where(demo_id: current_user.demo_id).alphabetical
  end

  def render_search_results_as_json
    results = @search_results.map{|search_result| search_result_for_autocomplete(search_result)}
    render inline: results.to_json
  end

  def search_result_for_autocomplete(search_result)
    {
      label: ERB::Util.h(search_result.name),
      value: {
        url: "http://www.google.com"
      }
    }
  end

  def find_current_board
    current_user.demo
  end
end
