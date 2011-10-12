def expect_src(selector, expected_src)
  matching_elements = all(:css, selector)
  matching_elements.should_not be_empty

  matching_elements.each do |matching_element|
    matching_element['src'].gsub(/\?.*$/, '').should == "/images/#{expected_src}"
  end
end

def expect_style(selector, style_key, style_value='', sense=true)
  embedded_styles = all(:css, 'style')
  if embedded_styles.empty?
    raise "no embedded styles found" if sense
    return
  end

  style_stanza = embedded_styles.map(&:text).join

  unless style_stanza =~ /#{selector}\s*\{(.*?)\ \!important\}/im
    raise "no embedded CSS rule for #{selector} found" if sense
    return
  end

  # Map a CSS rule stanza to a hash:
  #
  # foo: bar;
  # baz: quux;
  #
  # goes to {"foo" => "bar", "baz" => "quux"}
  
  rules = Hash[$1.split(/\;/).map(&:strip).map{|r| r.split(/\s*:\s*/)}]
 
  if sense
    rules[style_key].should == style_value
  else
    rules[style_key].should_not be_present
  end
end

def expect_no_style(selector, style_key)
  expect_style(selector, style_key, '', false)
end

def selector_for_elements(element_type)
  result = {
    'logo'                 => '#logo img',
    'play now button'      => "#add-action input[type=image]",
    'see more button'      => "input#see-more, input#show-all-ranked-players, .see-more",
    'save button'          => "#save-phone, #save-avatar, #save-username, #save-text-settings",
    'clear picture button' => "#clear-picture",
    'victory graphics'     => '.top-scores img',
    'fan button'           => '.be-a-fan',
    'de-fan button'        => '.defan',
    'header background'    => 'div.header',
    'nav links'            => '.header .inner-header #account a, .header .inner-header #account a:visited, .header .inner-header #account a:link',
    'active nav link'      => '.header .inner-header #account a.current-section, .header .inner-header #account a.current-section:visited, .header .inner-header #account a.current-section:link',
    'profile links'        => '.act-details .user a, .top-scores a .name, .fan-column .associate-details a, .fan-column .associate-details a:visited',
    'activity feed points' => '.act-details .points .point-value',
    'scoreboard points'    => '.top-scores .score',
    'column headers'       => '#secondary h2'
  }[element_type]

  raise "element type \"#{element_type}\" not known" unless result
  result
end

Then /^(the )?(.*?) should have src "([^"]*)"$/ do |_nothing, element_type, expected_src|
  expect_src(selector_for_elements(element_type), expected_src)
end

Then /^(the )?(.*?) should have no element graphic$/ do |_nothing, element_type|
  expect_no_style(selector_for_elements(element_type), 'background')
end

Then /^(the )?(.*?) should have no element color$/ do |_nothing, element_type|
  expect_no_style(selector_for_elements(element_type), 'color')
end

Then /^(the )?(.*?) should have element graphic "([^"]*)"$/ do |_nothing, element_type, expected_background_url|
  expect_style(selector_for_elements(element_type), 'background', "url('#{expected_background_url}')")
end

Then /^(the )?(.*?) should have element color "([^"]*)"$/ do |_nothing, element_type, expected_color|
  expect_style(selector_for_elements(element_type), 'color', expected_color)
end

Then /^(the )?(.*?) should have background color "([^"]*)"$/ do |_nothing, element_type, expected_color|
  expect_style(selector_for_elements(element_type), 'background-color', expected_color)
end

Then /^(the )?(.*?) should have no background color$/ do |_nothing, element_type|
  expect_no_style(selector_for_elements(element_type), 'background-color')
end

