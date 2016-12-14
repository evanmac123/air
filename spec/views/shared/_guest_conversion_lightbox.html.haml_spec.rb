require "spec_helper"

describe "shared/_guest_conversion_lightbox.html.haml" do
  def standard_locals
    @_locals ||= {
      user: FactoryGirl.create(:guest_user),
      demo: FactoryGirl.create(:demo),
      show_conversion_form: false
    }
  end

  def location_placeholder_text
    "Work Location"
  end

  it "should display the location autocomplete if the board in question uses it" do
    render "shared/guest_conversion_lightbox", standard_locals
    rendered.should_not include(location_placeholder_text)
  end
end
