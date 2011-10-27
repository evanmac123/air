Feature: User requests rules

  Scenario: User requests rules
    Given the following user exists:
      | phone number |
      | +14155551212 |
    When "+14155551212" sends SMS "rules"
    Then "+14155551212" should have received the following SMS:
    """
    FAN [someone's ID] - become a fan (ex: "fan bob12")
    MYID - see your ID
    RANKING - see scoreboard
    HELP - help desk, instructions
    PRIZES - see what you can win
    """
