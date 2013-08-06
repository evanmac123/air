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

    custom_plain_text: %{Welcome to H.Engage! 

An easy and fun way to learn about programs, benefits and other happenings at your company.

Get started at [invitation_url]
 
 
What does H.Engage do?

* Makes workplace communications feel fun and interesting.
* Provides short and timely content that's relevent for you.
* Reduces the volume of dense emails so you don't miss important information.
 

How it works:

* Start. Go to [invitation_url] to get started.
* Answer questions for points. Each week, we'll post new content on H.Engage. When there's new content, you'll receive a notification email.
* Win prizes. For every 20 points you earn, you'll get a ticket into the raffle for the prize. You can track the points and tickets you earn in the progress bar at the top of H.Engage's homepage.  


Questions? Send us a message at support@hengage.com.
    },

    custom_html_text: %{
<center>
<table width="550" cellspacing="0" cellpadding="0" border="0">
  <tr><td height="10">&nbsp;</td></tr>
  <tr style="font-family: 'helvetica neue', helvetica, sans-serif;">
    <td style="text-align:left;">
      <h1 style="color:#292929; font-weight:lighter; font-weight: 300;">Welcome to H.Engage!</h1>
      <h2 style="color: #a8a8a8; font-weight:bold; font-weight: 500;">An easy and fun way to learn about programs, benefits and other happenings at your company.</h2> </td>
    </td>
  </tr>
  <tr><td height="10">&nbsp;</td></tr>
  <tr>
    <td><center>
      <table cellspacing="0" cellpadding="0" border="0">
        <tr style="background:#4DA968;">
          <td colspan="3" height="0" style="line-height:.65em">&nbsp;</td>
        </tr>
        <tr style="background:#4DA968;">
          <td width="30">&nbsp;</td>
          <td><a style="color: #ffffff; display: block; font-family: 'helvetica neue', helvetica, sans-serif; font-size: 20px; font-weight:bold; text-decoration: none; padding:.5em 2em;" href="[invitation_url]" target="_blank">Get started</a></td>
          <td width="30">&nbsp;</td>
        </tr>
        <tr style="background:#4DA968;">
          <td colspan="3" height="0" style="border-bottom:5px #428E50 solid; line-height:.65em;">&nbsp;</td>
        </tr>
      </table>
    </center></td>
  </tr>
  <tr><td height="50">&nbsp;</td></tr>
  <tr style="font-family: 'helvetica neue', helvetica, sans-serif;">
    <td style="text-align:left;">
      <h2 style="color: #50698c; font-weight:bold; font-weight:500;">What does H.Engage do?</h2>
      <ul style="list-style-type:disc;"> 
        <li style="padding-bottom: 0.7em;">Makes workplace communications feel fun and interesting.</li> 
        <li style="padding-bottom: 0.7em;">Provides short and timely content that's relevent for you. </li> 
        <li style="padding-bottom: 0.7em;">Reduces the volume of dense emails so you don't miss important information.</li> 
      </ul> 
    </td>
  </tr>
  <tr><td height="10">&nbsp;</td></tr>
  <tr style="font-family: 'helvetica neue', helvetica, sans-serif;">
    <td style="text-align:left;">
      <h2 style="color: #50698c; font-weight:bold; font-weight:500;">How it works:</h2> 
      <ul style="list-style-type:disc;"> 
        <li style="padding-bottom: 0.7em;"><strong>Start.</strong> Click the green "Get started" button.</li> 
        <li style="padding-bottom: 0.7em;"><strong>Answer questions for points. </strong>Each week, we'll post new content on H.Engage. When there's new content, you'll receive a notification email. </li> 
        <li style="padding-bottom: 0.7em;"><strong>Win prizes. </strong>For every 20 points you earn, you'll get a ticket into the raffle for the prize. You can track the points and tickets you earn in the progress bar at the top of H.Engage's homepage.</li> 
      </ul> 
    </td>
  </tr>
  <tr>
    <td height="10">&nbsp;</td>
  </tr>
  <tr style="font-family: 'helvetica neue',helvetica, sans-serif;">
    <td style="text-align:center;">Questions? Send us a message at <a href="mailto:support@hengage.com">support@hengage.com</a></td>
  </tr>
  <tr>
    <td height="50">&nbsp;</td>
  </tr>
</table>
</center>

    }
  }
end
