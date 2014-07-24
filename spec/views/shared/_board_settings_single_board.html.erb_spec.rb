require "spec_helper"

describe "shared/_board_settings_single_board.html.erb" do
  def expect_no_delete_link
    rendered.should_not have_link("X", href: "#")
  end

  def expect_digest_muted
    rendered.should have_css('.digest_mute[checked]')
    rendered.should_not have_css('.digest_unmute[checked]')
  end

  def expect_followup_muted
    rendered.should have_css('.followup_mute[checked]')
    rendered.should_not have_css('.followup_unmute[checked]')
  end

  def expect_digest_unmuted
    rendered.should_not have_css('.digest_mute[checked]')
    rendered.should have_css('.digest_unmute[checked]')
  end

  def expect_followup_unmuted
    rendered.should_not have_css('.followup_mute[checked]')
    rendered.should have_css('.followup_unmute[checked]')
  end

  def expect_followup_enabled
    rendered.should_not have_css('.followup_mute[disabled]')
    rendered.should_not have_css('.followup_unmute[disabled]')

    rendered.should_not have_css(".followup_wrapper.disabled")
  end

  def expect_followup_disabled
    rendered.should have_css('.followup_mute[disabled]')
    rendered.should have_css('.followup_unmute[disabled]')

    rendered.should have_css(".followup_wrapper.disabled")
  end

  def standard_locals(overrides = {})
    {
      as_admin: false,
      digest_is_muted: false,
      followup_is_muted: false,
      board: FactoryGirl.build_stubbed(:demo)
    }.merge(overrides)
  end

  def render_single_board(local_overrides = {})
    render "shared/board_settings_single_board", standard_locals(local_overrides)
  end

  it "should not display delete links for paid boards" do
    render_single_board(board: FactoryGirl.build_stubbed(:demo, :paid))
    expect_no_delete_link
  end

  it "should not display delete links for boards you're in as a client admin" do
    render_single_board(as_admin: true)
    expect_no_delete_link
  end

  # The following craziness exists becuase, if you call render more than once
  # in a view spec, it appends the new results to the old ones in #rendered, 
  # rather than overwriting them. There may be a way to clear #rendered out
  # and have that do what we want in this case, but if so it's not documented
  # in any of the places I looked
  #
  # Purists would probably say that we shouldn't write view specs that do that
  # anyway, but who asked them?

  slider_test_settings = [ 
    [false, false, false, false, false],
    [true,  false, true,  true,  true],
    [false, true,  false, true,  false],
    [true,  true,  true,  true,  true]
  ]

  slider_test_settings.each do |digest_is_muted, followup_is_muted, expect_digest_slider_muted, expect_followup_slider_muted, expect_followup_slider_disabled|
    context "when digest_is_muted is #{digest_is_muted} and followup_is_muted is #{followup_is_muted}" do
      before do
        render_single_board(digest_is_muted: digest_is_muted, followup_is_muted: followup_is_muted)
      end

      if expect_digest_slider_muted
        it "should have the digest slider show as muted" do
          expect_digest_muted
        end
      else
        it "should have the digest slider show as unmuted" do
          expect_digest_unmuted
        end
      end

      if expect_followup_slider_muted
        it "should have the followup slider show as muted" do
          expect_followup_muted
        end
      else
        it "should have the followup slider show as unmuted" do
          expect_followup_unmuted
        end
      end

      if expect_followup_slider_disabled
        it "should expect the followup slider to be disabled" do
          expect_followup_disabled
        end
      else
        it "should expect the followup slider to be enabled" do
          expect_followup_enabled
        end
      end
    end
  end
end
