Feature: User follows links in suggested task

  Scenario: A suggested task with a link in it is follow-able
    Given the following demo exists:
      | company_name |
      | Linkeria Inc |
    # LOLHAX. But due to the way that Capybara seems to not play well with
    # external URLs (which is reasonable on reflection) we have to test this 
    # with a URL local to the site.
    And the following suggested task exists:
      | name                                     | short description                           | long description                                     | demo                       |
      | <a href="/account/settings/edit">Click me</a> | <a href="/account/settings/edit">Go on do it</a> | <a href="/account/settings/edit">Find out what's here</a> | company_name: Linkeria Inc |
    And the following user exists:
      | name | demo                       |
      | Bob  | company_name: Linkeria Inc |
    And "Bob" has the password "foobar"

    When I sign in via the login page as "Bob/foobar"
    And I follow "Click me"
    Then I should be on the settings page

    When I go to the activity page
    And I follow "Go on do it"
    Then I should be on the settings page

    When I go to the activity page
    And I follow "More info"
    And I follow "Find out what's here"
    Then I should be on the settings page
