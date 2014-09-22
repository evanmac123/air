class LocationsController < ApplicationController
  prepend_before_filter :allow_guest_user

  def index
    find_search_results
    render_search_results_as_json
  end

  protected

  def find_search_results
    normalized_term = params[:term].downcase.strip.gsub(/\s+/, ' ')
    location_names = Location.name_ilike(normalized_term).where(demo_id: current_user.demo_id).alphabetical.pluck(:name)
    @search_results = LocationAutocompleteResults.from_location_names(location_names)
  end

  def render_search_results_as_json
    render inline: @search_results.to_json
  end

  def find_current_board
    current_user.demo
  end



  class LocationAutocompleteResults
    def initialize(location_names)
      @location_names = location_names
    end

    def to_json
      search_results_for_autocomplete.to_json
    end

    def self.from_location_names(location_names)
      if location_names.empty?
        NullLocationAutocompleteResults.new
      else
        LocationAutocompleteResults.new(location_names)
      end
    end

    protected

    def search_results_for_autocomplete
      @location_names.map{|location_name| search_result_for_autocomplete(location_name)}
    end

    def search_result_for_autocomplete(location_name)
      {
        label: ERB::Util.h(location_name),
        value: {
          found: found
        }
      }
    end

    def found
      true
    end
  end

  class NullLocationAutocompleteResults < LocationAutocompleteResults
    def initialize
      @location_names = ["Sorry, we cannot find that location. Try again."]
    end

    def found
      false
    end
  end
end
