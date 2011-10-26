Feature: User requests help

  Scenario: User requests help
    Given the following user exists:
      | phone number |
      | +14155551212 |
    When "+14155551212" sends SMS "help"
    Then "+14155551212" should have received an SMS "Text:\nRULES for command list\nPRIZES for prizes\nSUPPORT for help from the help desk"

  Scenario: Help requested for a demo with custom help message
    Given the following demo exists:
      | company name | help message |
      | 1D10T        | Panic!       |
    And the following user exists:
      | phone number | demo                |
      | +16175551212 | company_name: 1D10T |
    When "+16175551212" sends SMS "help"
    Then "+16175551212" should have received SMS "Panic!"
