class CustomInvitationEmail < ActiveRecord::Base
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

  def interpolate_invitation_url(invitation_url, text)
    interpolate_self_closing_tag('invitation_url', invitation_url, text)
  end

  def interpolate_self_closing_tag(tag_name, text_to_interpolate, text)
    text.gsub(/\[#{tag_name}\]/, text_to_interpolate)
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
    custom_subject: "Play [game_name] Now and Learn about your HR Benefits",
    custom_subject_with_referrer: "[referrer] Invited you to Play [game_name] and Learn about HR Benefits",

    custom_plain_text: %{PLAY AT WORK

[game_name] is the new game brought to you by your HR department and H Engage. Playing will help you learn about and get the most from your HR benefits and programs.

It's fun and easy. You can play via text message, email or online from any device -- at work, at home or on the go. 

Go to [invitation_url] to play now.},


    custom_html_text: %{<h2>Play at Work</h2>

<p>[game_name] is the new game brought to you by your HR department and H Engage. Playing will help you learn about and get the most from your HR benefits and programs.</p>

<p>It's fun and easy. You can play via text message, email or online from any device -- at work, at home or on the go.</p>

<p><a href="[invitation_url]">Click here</a> to play now.</p>}
  }
end
