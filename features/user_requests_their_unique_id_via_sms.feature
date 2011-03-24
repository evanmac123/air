Feature: User requests their unique ID by SMS

  Scenario: User requests their unique ID by SMS
    Given the following user exists:
      | name           | phone number |
      | Phil Darnowsky | +14152613077 |
    And "Phil Darnowsky" has the SMS slug "iamgod"
    When "+14152613077" sends SMS "myid"
    Then "+14152613077" should have received an SMS "Your unique ID is iamgod."

  Scenario: Nonexistent user requests their unique ID by SMS
    When "+14152613077" sends SMS "myid"
    Then "+14152613077" should have received an SMS 'I can't find your number in my records. Did you claim your account yet? If not, text your first initial and last name (if you are John Smith, text "jsmith").'
