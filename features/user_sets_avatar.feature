Feature: User sets avatar
  Background:
    Given the following demo exists:
      | name |
      | Big Machines |
    Given the following claimed users exist:
      | name  | phone number | email             | demo                      |
      | Phil  | +14155551212 | phil@example.com  | name: BigMachines |
    And "Phil" has the password "foobar"
    And I sign in via the login page with "Phil/foobar"
    And I go to the settings page for "Phil"

  Scenario: User can set their avatar
    When I attach the avatar "alistair.jpg"
    And I press the avatar submit button
    Then I should be on the settings page
    Then I should see an avatar "alistair.jpg" for "Phil"

  @slow
  Scenario: User can change a set avatar
    When I attach the avatar "alistair.jpg"
    And I press the avatar submit button
    And I attach the avatar "maggie.jpg"
    And I press the avatar submit button
    Then I should be on the settings page
    And I should see an avatar "maggie.jpg" for "Phil"

  Scenario: User gets sensible error if they try to set avatar without choosing a file
    When I press the avatar submit button
    Then I should be on the settings page
    And I should see the default avatar for "Phil"
    And I should see "Please choose a file to use for your avatar."

  @slow
  Scenario: User can delete their avatar
    When I attach the avatar "alistair.jpg"
    And I press the avatar submit button
    When I press the avatar clear button
    Then I should be on the settings page
    And I should see the default avatar for "Phil"  

  Scenario: User tries to upload some random garbage file for an avatar
    When I attach the avatar "herpderp.doc"
    And I press the avatar submit button
    Then I should be on the settings page
    And I should see the default avatar for "Phil"
    And I should see "Sorry, I didn't understand that file you tried to upload as an image file."

    When I attach the avatar "alistair.jpg"
    And I press the avatar submit button
    Then I should be on the settings page
    And I should see an avatar "alistair.jpg" for "Phil"

    When I attach the avatar "herpderp.doc"
    And I press the avatar submit button
    Then I should be on the settings page
    And I should see "Sorry, I didn't understand that file you tried to upload as an image file."    
    And I should see an avatar "alistair.jpg" for "Phil"
