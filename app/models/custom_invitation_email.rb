class CustomInvitationEmail < ActiveRecord::Base
  include EmailInterpolations::SelfClosingTag
  include EmailInterpolations::InvitationUrl
  extend EmailHelper

  belongs_to :demo

  validates_presence_of :demo_id

  def subject(user, referrer, invitation_url)
    if referrer
      interpolate_everything(user, referrer, invitation_url, custom_or_default(:custom_subject_with_referrer))
    else
      interpolate_everything(user, referrer, invitation_url, custom_or_default(:custom_subject))
    end
  end

  def html_text(user, referrer, invitation_url)
    interpolate_everything(user, referrer, invitation_url, custom_or_default(:custom_html_text))
  end

  def plain_text(user, referrer, invitation_url)
    interpolate_everything(user, referrer, invitation_url, custom_or_default(:custom_plain_text))
  end

  protected

  def interpolate_everything(user, referrer, invitation_url, text)
    result = select_referrer_blocks(referrer, text)
    result = interpolate_referrer(referrer, result)
    result = interpolate_game_name(result)
    result = interpolate_user_name(user, result)
    result = interpolate_invitation_url(invitation_url, result)
  end

  def custom_or_default(field_name)
    self.send(field_name) || DEFAULTS[field_name]
  end

  def interpolate_referrer(referrer, text)
    return text unless referrer
    interpolate_self_closing_tag('referrer', referrer.name, text)
  end

  def interpolate_user_name(user, text)
    interpolate_self_closing_tag('user', user.name, text)
  end

  def interpolate_game_name(text)
    interpolate_self_closing_tag('game_name', demo.name, text)
  end

  def select_referrer_blocks(referrer, text)
    if referrer.present?
      strip_tags(text, 'referrer_block' => :clean, 'no_referrer_block' => :remove)
    else
      strip_tags(text, 'no_referrer_block' => :clean, 'referrer_block' => :remove)
    end
  end

  def strip_tags(text, handling)
    result = text.dup

    handling.each do |tag_name, disposition|
      open_tag = %!\\[#{tag_name}\\]!
      close_tag = %!\\[/#{tag_name}\\]!

      case disposition
      when :remove
        result.gsub!(/#{open_tag}(.*?)#{close_tag}\n?/m, '')
      when :clean
        result.gsub!(/(#{open_tag}|#{close_tag})/m, '')
      end
    end

    result
  end

  DEFAULTS = {
    custom_subject: "Play [game_name] and make the most of your HR programs and benefits",

    custom_subject_with_referrer: "[referrer] invited you to play [game_name] and make the most of your HR programs and benefits",

    custom_plain_text: %{Welcome to H Engage! A fun social app that helps you make the most of HR programs and benefits.
  
      Get started at [invitation_url]

      How it works:

      1.) Read tiles: Bite-size messages and information about your programs and benefits.

      2.) Earn points: Check-in and answer questions.

      3.) Win prizes: Redeem points for entries toward great prizes!
  },

    custom_html_text: %{
      <center><div style="font-size:14px;width:500px;">
        <h1 style="color:#9a9a9a;font-size:2em;font-weight:300;">Welcome to H Engage!</h1>
        <p>A fun social app that helps you make the most of HR programs and benefits.</p>

        #{link_styled_like_button "Get started", "[invitation_url]"}

        <h2 style="color:#9a9a9a;font-size:1.3em;font-weight:300;">How it works:</h2>
        <table width="100%" border="0" cellspacing="10" style="font-size:14px; text-align:left;">
          <tr>
            <td width="33%" valign="top"><b>Read tiles:</b><br/>Bite-size messages and information about your programs and benefits.</td>
            <td width="33%" valign="top"><b>Earn points:</b><br/> Check-in and answer questions.</td>
            <td width="33%" valign="top"><b>Win prizes:</b><br/> Redeem points for entries toward great prizes!</td>
          </tr>
        </table>
      </div></center>
    }
  }
end
