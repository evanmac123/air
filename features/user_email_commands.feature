Feature: User acts via email

  Background:
    Given the following claimed users exist:
      | email             |
      | dan@bigco.com     |

  Scenario: User sends email with blank body and gets a reasonable response
    When "dan@bigco.com" sends email with subject "" and body ""
    Then "dan@bigco.com" should receive 1 email
    When "dan@bigco.com" opens the email
    Then I should see "We got your email, but it looks like the body of it was blank. Please put your command in the first line of the email body." in the email body
