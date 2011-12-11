module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'
    when /the activity page/
      '/activity'
    when /the admin page/
      admin_path
    when /the admin "(.*)" demo page$/i
      admin_demo_path(Demo.find_by_company_name($1))
    when /the invitation page for "(.*)"/
      user = User.find_by_email($1)
      invitation_path(user.invitation_code)
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

    when /the (friends|connections) page/
      friends_path

    when /the user directory page/
      users_path

    when /the user page for "(.*?)"/
      user_path(User.find_by_name($1))

    when /the admin rules page for "(.*?)"/
      admin_demo_rules_path(Demo.find_by_company_name($1))

    when /the admin goals page for "(.*?)"/
      admin_demo_goals_path(Demo.find_by_company_name($1))

    when /the admin bad words page for "(.*?)"/
      admin_demo_bad_words_path(Demo.find_by_company_name($1))

    when /the rule edit page for "(.*?)"/
      rule_value = RuleValue.find_by_value($1)
      rule = rule_value.rule
      edit_admin_rule_path(rule)

    when /the admin rules page for the standard rulebook/
      admin_rules_path

    when /the blast SMS page for "(.*?)"/
      new_admin_demo_blast_sms_path(Demo.find_by_company_name($1))

    when /the marketing page/
      page_path(:id => 'marketing')

    when /the user bulk upload page for "(.*?)"/
      new_admin_demo_bulk_load_path(Demo.find_by_company_name($1))

    when /the forbidden rule admin page/
      admin_forbidden_rules_path

    when /the admin suggested tasks page for "(.*?)"/
      admin_demo_suggested_tasks_path(Demo.find_by_company_name($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
