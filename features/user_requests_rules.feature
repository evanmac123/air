Feature: User requests rules

  Scenario: User requests rules
    Given the following user exists:
      | phone number |
      | +14155551212 |
    When "+14155551212" sends SMS "rules"
    Then "+14155551212" should have received an SMS `FAN [someone's ID] - become a fan (ex: "fan bob12")\nMYID - see your ID\nRANKING - see scoreboard\nHELP - help desk, instructions\nPRIZES - see what you can win`
