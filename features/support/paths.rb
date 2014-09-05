module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /^the home\s?page$/
      '/'
    when /the activity page( with HTML forced)?/
      if($1)
        activity_path(:format => :html)
      else
        activity_path
      end
    when /the admin page/
      admin_path
    when /the directory page/
      users_path
    when /the help page/
      faq_path
    when /the admin edits user "(.*)" in the "(.*)" demo$/
      admin_demo_user_path Demo.find_by_name($2), User.find_by_name($1)
    when /the admin reports page for "(.*)"$/
      admin_demo_reports_path(Demo.find_by_name($1))
    when /the admin "(.*)" demo page$/i
      admin_demo_path(Demo.find_by_name($1))
    when /the admin "(.*)" user-by-location page$/
      admin_demo_reports_location_breakdown_path(Demo.find_by_name($1))
    when /the admin "(.*)" locations page$/
      admin_demo_locations_path(Demo.find_by_name($1))
    when /the invitation page for "(.*)"/
      user = User.find_by_email($1)
      invitation_path(user.invitation_code)
    when "the new invitation page"
      new_invitation_path
    when "the invitation resend page"
      new_invitation_resend_path
    when /the profile page for "(.*)"/
      user = User.find_by_name($1)
      user_path(user.slug)
    when /the bad message log page/
      admin_bad_messages_path

    when /the static (.*) page/
      "/pages/#{$1}"

    when /the password reset request page/
      new_password_path

    when /the password reset page for "(.*?)"/
      user = User.find_by_name($1)
      raise "trying to determine password reset page for user with no confirmation token" unless user.confirmation_token.present?
      edit_user_password_path(:user_id => user.id, :token => user.confirmation_token)

    when /the password reset full URL for "(.*?)"/
      user = User.find_by_name($1)
      raise "trying to determine password reset URL for user with no confirmation token" unless user.confirmation_token.present?
      edit_user_password_url(:user_id => user.id, :token => user.confirmation_token)

    when /the user directory page/
      users_path

    when /the user page for "(.*?)"/
      user_path(User.find_by_name($1))

    when /the admin rules page for the standard playbook/
      admin_rules_path

    when /the admin rules page for "(.*?)"/
      admin_demo_rules_path(Demo.find_by_name($1))

    when /the rule edit page for "(.*?)"/
      rule_value = RuleValue.find_by_value($1)
      rule = rule_value.rule
      edit_admin_rule_path(rule)

    when /the admin rules page for the standard rulebook/
      admin_rules_path

    when /the new admin rule page/
      new_admin_rule_path

    when /the marketing page/
      page_path(:id => 'marketing')

    when /the user bulk upload page for "(.*?)"/
      new_admin_demo_bulk_load_path(Demo.find_by_name($1))

    when /the forbidden rule admin page/
      admin_forbidden_rules_path

    when /the admin tiles page for "(.*?)"/
      admin_demo_tiles_path(Demo.find_by_name($1))

    when /the edit admin demo user page for company "(.*?)" and user "(.*?)"/
      edit_admin_demo_user_path(Demo.find_by_name($1).id, User.find_by_name($2).slug)

    when /the edit admin tile page for company "(.*?)" and tile "(.*?)"/
      edit_admin_demo_tile_path(Demo.find_by_name($1), Tile.find_by_headline($2))

    when /the new admin tag page/
      new_admin_tag_path

    when /the settings page/
      edit_account_settings_path

    when /the (login|sign-in|sign in|signin) page/
      sign_in_path

    when /the interstitial phone (verification|validation) page/
      phone_verification_path

    when /the manage tiles page/
      client_admin_tiles_path

    else

      begin
        page_name =~ /^the (.*) page$/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue NoMethodError, ArgumentError
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
