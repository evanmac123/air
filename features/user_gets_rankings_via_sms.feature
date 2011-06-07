Feature: User gets rankings via SMS

  Background:
    Given the following users exist:
      | name                | phone_number | points | demo                |
      | Phil Darnowsky      | +14155551212 | 250    | company_name: FooCo |
      | Vlad Gyster         | +14155551213 | 238    | company_name: FooCo |
      | Tony Wu             | +14155551214 | 237    | company_name: FooCo |
      | Dan Croak           | +14155551215 | 237    | company_name: FooCo |
      | Kelli Peterson      | +14155551216 | 225    | company_name: FooCo |
      | Peggy Bartek        | +14155551217 | 220    | company_name: FooCo |
      | MaryLynne Karman    | +14155551218 | 219    | company_name: FooCo |
      | Kristina Rikantis   | +14155551219 | 218    | company_name: FooCo |
      | Kirill Bernshteyn   | +14155551220 | 215    | company_name: FooCo |
      | Darryl Whatshisname | +14155551221 | 210    | company_name: FooCo |
      | Audrey Roth         | +14155551222 | 205    | company_name: FooCo |

  Scenario: User gets pages of rankings
    When "+14155551212" sends SMS "rankings"
    And "+14155551212" sends SMS "morerankings"
    Then "+14155551212" should have received an SMS "1. Phil Darnowsky (250)\n2. Vlad Gyster (238)\n3. Dan Croak (237)\n3. Tony Wu (237)\n5. Kelli Peterson (225)\n6. Peggy Bartek (220)\nSend MORERANKINGS for more."
    And "+14155551212" should have received an SMS "7. MaryLynne Karman (219)\n8. Kristina Rikantis (218)\n9. Kirill Bernshteyn (215)\n10. Darryl Whatshisname (210)\n11. Audrey Roth (205)\nSend MORERANKINGS for more."

  Scenario: User asks for more rankings without having gotten any yet
    When "+14155551212" sends SMS "morerankings"
    And "+14155551212" sends SMS "morerankings"
    Then "+14155551212" should have received an SMS "1. Phil Darnowsky (250)\n2. Vlad Gyster (238)\n3. Dan Croak (237)\n3. Tony Wu (237)\n5. Kelli Peterson (225)\n6. Peggy Bartek (220)\nSend MORERANKINGS for more."
    And "+14155551212" should have received an SMS "7. MaryLynne Karman (219)\n8. Kristina Rikantis (218)\n9. Kirill Bernshteyn (215)\n10. Darryl Whatshisname (210)\n11. Audrey Roth (205)\nSend MORERANKINGS for more."

  Scenario: User comes to end of rankings
    Given "Phil Darnowsky" has ranking query offset 10
    And "+14155551212" sends SMS "morerankings"
    And "+14155551212" sends SMS "morerankings"
    And "+14155551212" sends SMS "morerankings"
    Then "+14155551212" should have received SMS "11. Audrey Roth (205)\nSend MORERANKINGS for more."
    And "+14155551212" should have received SMS "That's everybody! Send RANKINGS to start over from the top."
    And "+14155551212" should have received SMS "1. Phil Darnowsky (250)\n2. Vlad Gyster (238)\n3. Dan Croak (237)\n3. Tony Wu (237)\n5. Kelli Peterson (225)\n6. Peggy Bartek (220)\nSend MORERANKINGS for more."

  Scenario: RANKINGS resets query offset
    Given "Phil Darnowsky" has ranking query offset 10
    And "+14155551212" sends SMS "rankings"
    And "+14155551212" sends SMS "morerankings"
    Then "+14155551212" should have received SMS "1. Phil Darnowsky (250)\n2. Vlad Gyster (238)\n3. Dan Croak (237)\n3. Tony Wu (237)\n5. Kelli Peterson (225)\n6. Peggy Bartek (220)\nSend MORERANKINGS for more."
    And "+14155551212" should have received SMS "7. MaryLynne Karman (219)\n8. Kristina Rikantis (218)\n9. Kirill Bernshteyn (215)\n10. Darryl Whatshisname (210)\n11. Audrey Roth (205)\nSend MORERANKINGS for more."
