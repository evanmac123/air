Feature: User views activity

  # @akephalos @mobile
  # Scenario: User views activity on their mobile phone
  #   Given the following user exists:
  #     | name | phone number | demo                  | password | password confirmation |
  #     | Dan  | +15087407520 | company_name: FooCorp | password | password              |
  #   And the following rules exist:
  #     | key          | value  | points |
  #     | name: ate    | banana | 2      |
  #     | name: worked | out    | 5      |
  #   When "+15087407520" sends SMS "ate banana"
  #   And I sign in via the login page as "Dan/foo"
  #   And I go to the acts page
  #   Then I should see the following act:
  #     | name | act         | points |
  #     | Dan  | ate banana  | 2      |
  #   When I follow "Dan"
  #   Then I should be on the profile page for "Dan"
  #   And I should see "2 points"
  #   And I should see "0 followers"
  #   And I should see "0 following"
