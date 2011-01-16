Feature: Visitor signs up

  Scenario: Visitor signs up
    Given a demo exists with a company name of "Alpha"
    And I am on the homepage
    And I follow "Sign up"
    When I fill in "Name" with "Dan Croak"
    And I fill in "Email" with "dcroak@thoughtbot.com"
    And I fill in "Enter your mobile number" with "508-740-7520"
    And I press "Submit"
    Then "+5087407520" should have received an SMS "You've joined the Alpha game!"
