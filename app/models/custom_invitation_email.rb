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
    result = interpolate_headline(referrer, result)
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

  def interpolate_headline(referrer, text)
    if referrer
      interpolate_self_closing_tag('headline', "#{referrer.name} invited you to", text)
    else
      interpolate_self_closing_tag('headline', "You are invited to", text)
    end
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
    custom_subject: "Your invitation to join the [game_name]",

    custom_subject_with_referrer: "[referrer] invited you to join the [game_name]",

    custom_plain_text: %{
Your invitation to the [game_name].

Our social space to feature what you should know and do. Read, take actions, and earn points.

Get started at [invitation_url]

Questions? Email support@air.bo.


    },

    custom_html_text: %{
<center>
  <table cellspacing="0" cellpadding="0" border="0">
    <tr><td height="10">&nbsp;</td></tr>
    <tr style="font-family: 'helvetica neue', helvetica, sans-serif;">
      <td style="font-family:Helvetica,Arial,sans-serif;font-size:24px;color:#4c4c4c;mso-line-height-rule:exactly;line-height:30px;padding-top:40px;padding-bottom:20px;text-align: center;">
        [headline]
        <br/>
        join the [game_name]
      </td>
    </tr>
    <tr>
      <td style="font-family:Helvetica,Arial,sans-serif;font-size:16px;color:#a8a8a8;mso-line-height-rule:exactly;line-height:24px;padding-bottom:60px;word-break: break-word;text-align: center;">
        Our social space to feature what you should know and do. Read, take actions, and earn points.
      </td>
    </tr>
    <tr><td height="10">&nbsp;</td></tr>
  </table>
</center>

    }
  }
end
