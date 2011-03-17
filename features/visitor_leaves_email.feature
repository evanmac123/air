Feature: Contact us

  In order to get more information
  As a visitor
  I want to leave my email address for H Engage

  Scenario: Visitor contacts us
    Given I go to the home page
    And I fill in "Email" with "barry@example.com"
    And I press "Contact us"
    Then I should see "Thanks for contacting us."
    And "vlad@hengage.com" should receive an email
    When "vlad@hengage.com" opens the email with subject "Contact us"
    Then he should see "barry@example.com" in the email body
