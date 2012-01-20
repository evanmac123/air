Feature: User requests their user ID by SMS

  Background:
    Given the following user exists:
      | name           | phone number |
      | Phil Darnowsky | +14152613077 |
    And "Phil Darnowsky" has the SMS slug "iamgod"

  Scenario: User requests their user ID by SMS
    When "+14152613077" sends SMS "myid"
    Then "+14152613077" should have received an SMS "Your user ID is iamgod."

  Scenario: User requests their user ID via the website
    Given "Phil Darnowsky" has the password "foobar"
    When I sign in via the login page as "Phil Darnowsky/foobar"
    And I enter the special command "myid"
    Then I should see the success message "Your user ID is iamgod."

  Scenario: Nonexistent user requests their user ID by SMS
    When "+14155551212" sends SMS "myid"
    Then "+14155551212" should have received an SMS 'I can't find your number in my records. Did you claim your account yet? If not, text your first initial and last name (if you are John Smith, text "jsmith").'
