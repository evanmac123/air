# Feature: Your score display

  # As a player
  # In order to know how I'm doing against others and stoke my competitive urges
  # I want to see my current score and ranking

  # Scenario: Your score displayed on dashboard
    # Given the following users exist:
      # | name | points | recent_average_points | demo                | phone_number |
      # | Lazy | 0      | 14                    | name: Alpha | +19435034923 |
      # | Tony | 24     | 41                    | name: Alpha | +15893948923 |
      # | Bleh | 2      | 19                    | name: Alpha | +15892384923 |
      # | Phil | 634923 | 46                    | name: Alpha | +19895834234 |
      # | Vlad | 17     | 25                    | name: Alpha | +19839582934 |
      # | Dan  | 10     | 43                    | name: Alpha | +15893842334 |
      # | Bob  | 0      | 0                     | name: Alpha |              |
    # And "Tony" has the password "whatnot"
    # And I sign in via the login page as "Tony/whatnot"
    # When I go to the acts page
    # Then I should see "24" points
    # And I should see "2nd out of 6" ranking
