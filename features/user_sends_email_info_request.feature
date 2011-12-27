Feature: User sends e-mail info request

@javascript
Scenario: User requests through the top box
  Given I am on the marketing page
  When I enter "James Hennessey IX" in the name field of the top email info box
  And I enter "james@henhen.com" in the email field of the top email info box
  And I submit the top email info box
  Then I should see "Thanks, we'll be in touch"

  When DJ cranks once
  And "vlad@hengage.com" opens the email
  Then they should see "James Hennessey IX" in the email body
  And they should see "james@henhen.com" in the email body
