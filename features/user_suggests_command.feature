Feature: User suggests command

  Background:
    Given the following users exist:
      | name           | phone number | demo                   |
      | Vlad Gyster    | +16175551212 | company_name: H Engage |
      | Phil Darnowsky | +14155551212 | company_name: H Engage |
    And "Vlad Gyster" has the password "foo"

  Scenario: User suggests we add the last bad command they sent
    When "+16175551212" sends SMS "ate pasta"
    And "+16175551212" sends SMS "S"
    Then we should have recorded that "Vlad Gyster" suggested "ate pasta"
    And "+16175551212" should have received an SMS "Thanks! We'll take your suggestion into consideration."
    
  Scenario: User suggests we add the last bad command they sent, and they included a referring user
    When "+16175551212" sends SMS "ate pasta pdarnowsky"
    And "+16175551212" sends SMS "S"
    Then we should have recorded that "Vlad Gyster" suggested "ate pasta"
    And "+16175551212" should have received an SMS "Thanks! We'll take your suggestion into consideration."

  Scenario: User suggests arbitrary command
    When "+16175551212" sends SMS "s ate pasta"
    Then we should have recorded that "Vlad Gyster" suggested "ate pasta"
    And "+16175551212" should have received an SMS "Thanks! We'll take your suggestion into consideration."

  Scenario: Unknown number suggests something
    When "+18088675309" sends SMS "s ate goat cheese"
    Then we should not have recorded any suggestions

  Scenario: "SUGGEST" is a synonym for "S"
    When "+16175551212" sends SMS "suggest ate pasta"
    Then we should have recorded that "Vlad Gyster" suggested "ate pasta"
    And "+16175551212" should have received an SMS "Thanks! We'll take your suggestion into consideration."

  Scenario: User suggests a command through the website
    When I sign in via the login page with "Vlad Gyster/foo"
    And I enter the special command "suggest ate kitten"
    Then I should see the success message "Thanks! We'll take your suggestion into consideration."
