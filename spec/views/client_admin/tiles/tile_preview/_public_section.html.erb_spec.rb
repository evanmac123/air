require "spec_helper"

describe "client_admin/tiles/tile_preview/_public_section.html.erb" do
  def mock_form(is_public)
    mock_tile = FactoryGirl.build_stubbed(:multiple_choice_tile, is_public: is_public)
    stub(
      object: mock_tile,
      text_field: nil,
      radio_button: nil,
      hidden_field: nil
    )
  end

  context "when passed a public tile" do
    it "should have the proper copy" do
      render "client_admin/tiles/tile_preview/public_section", form: mock_form(true), has_tags_class: ""
      rendered.should have_css('.share_to_explore.remove_from_explore', text: 'Remove')
    end
  end

  context "when passed a private tile" do
    it "should have the proper copy" do
      render "client_admin/tiles/tile_preview/public_section", form: mock_form(false), has_tags_class: ""
      rendered.should have_css('.share_to_explore', text: 'Share')
      rendered.should_not have_css('.share_to_explore.remove_from_explore')
    end
  end
end
