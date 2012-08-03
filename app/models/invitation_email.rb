class InvitationEmail
  include  ActionView::Helpers::SanitizeHelper 
    
  def self.wrap_and_sanitize(html)
    safe = strip_tags_except_bi(html)    
    lines = safe.split break_char
    paragraph = lines.join join_char
    paragraph.html_safe
  end

  def self.strip_tags(html)
    options = {}
    full_sanitizer.sanitize(html, options)
  end

  def self.strip_tags_except_bi(html)
    # Strip all tags except <b>, <i>
    options = {tags: %w(i b)}
    white_list_sanitizer.sanitize(html, options)
  end


  def self.break_char
    "\r\n"
  end

  def self.join_char
    "<br>"
  end

  def self.referrer_tag
    "[referrer]"
  end

  def self.referrer_tag_cap
    "[Referrer]"
  end

  def self.blurb(demo, referrer=nil)
    attribute = "invitation_blurb"
    attribute += "_with_referrer" if referrer
    default = "default_blurb"
    default += "_with_referrer" if referrer
    
    if demo.send(attribute).present?
      raw = demo.send(attribute)
    else
      raw = send(default, demo)
    end
    html = strip_tags_except_bi(raw)
    gsub_referrer(html, referrer).html_safe
  end

  def self.plain_blurb(demo, referrer=nil)
    html = blurb(demo, referrer)
    text = strip_tags(html)
  end
    

  def self.gsub_referrer(html, referrer)
    return html unless referrer
    html = strip_tags_except_bi(html)
    html.gsub!(referrer_tag, referrer.name)
    html.gsub(referrer_tag_cap, referrer.name)
  end

  def self.default_subject(demo)
    "Ready to play? #{demo.name_with_sponsor} starts today" 
  end

  def self.default_subject_with_referrer(demo)
    "[referrer] invited you to play #{demo.name_with_sponsor}"
  end

  def self.default_blurb(demo)
    game_name = strip_tags(demo.name)
    "#{game_name} is a fun social game that rewards you for making healthy decisions and hunting for colorful squares, called <i>tiles</i>. Earn points and win prizes like gift cards and iPads!".html_safe
  end

  def self.default_blurb_with_referrer(demo)
    game_name = strip_tags(demo.name_with_sponsor).html_safe
    "[referrer] has invited you to play #{game_name}. It's a fun social game that rewards you for making healthy decisions and hunting for colorful squares, called <i>tiles</i>. Earn points and win prizes like gift cards and iPads!".html_safe
  end

  # Set up the default values for bullets
  def self.bullet_defaults
    {'1' => "Finding tiles",
      '2' => "Eating fruits and veggies",
      '3' => "Exercising and making other\r\nhealthy choices"}
  end

  # Here is the ghost method 
  # Call it like this:  InvitationEmail.bullet_1(demo), InvitationEmail.bullet_2(demo), etc.
  def self.method_missing(id, *args, &block)
    demo = args[0]
    if id.to_s =~ /^bullet_(.+)$/
      attribute = "invitation_bullet_" + $1
      unless demo.kind_of? Demo 
        raise "You must call InvitationEmail.#{attribute} with an argument of class Demo"
      end
      if demo.send(attribute).present?
        raw = demo.send(attribute)
      else
        raw = self.bullet_defaults[$1]
      end
      return wrap_and_sanitize(raw)
    end
    super
  end

  class << self
    [1,2,3].each do |num|
      plain_attribute = "plain_bullet_" + num.to_s
      html_attribute = "bullet_" + num.to_s
      define_method plain_attribute do |demo|
        html = send(html_attribute, demo)
        text = strip_tags(html)
      end
    end
  end


  def self.subject(demo)
    attribute = :invitation_subject
    if demo.send(attribute).present?
      raw = demo.send(attribute)
    else
      raw = default_subject(demo)
    end
    strip_tags(raw)
  end

  def self.subject_with_referrer(demo, referrer)
    attribute = :invitation_subject_with_referrer
    if demo.send(attribute).present?
      raw = demo.send(attribute)
    else
      raw = default_subject_with_referrer(demo)
    end
    stripped = strip_tags(raw)
    gsub_referrer(stripped, referrer)
  end

      
end
