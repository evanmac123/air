Feature: User requests rules

  Scenario: User requests rules
    Given the following user exists:
      | phone number |
      | +14155551212 |
    When "+14155551212" sends SMS "rules"
    Then "+14155551212" should have received an SMS "FAN [someone's ID] - become a fan\nMYID - see your own ID\nRANKING - see rankings in your game\nHELP - get basic instructions\nPRIZES - see what you can win"
