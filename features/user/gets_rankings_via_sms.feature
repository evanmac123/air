Feature: User gets rankings via SMS

  Background:
    Given the following claimed users exist:
      | name                | phone_number | points | demo        |
      | Dan Croak           | +14155551215 | 237    | name: FooCo |
      | Audrey Roth         | +14155551222 | 205    | name: FooCo |
      | Kirill Bernshteyn   | +14155551220 | 215    | name: FooCo |
      | Tony Wu             | +14155551214 | 237    | name: FooCo |
      | Kelli Peterson      | +14155551216 | 225    | name: FooCo |
      | Peggy Bartek        | +14155551217 | 220    | name: FooCo |
      | MaryLynne Karman    | +14155551218 | 219    | name: FooCo |
      | Vlad Gyster         | +14155551213 | 238    | name: FooCo |
      | Phil Darnowsky      | +14155551212 | 250    | name: FooCo |
      | Kristina Rikantis   | +14155551219 | 218    | name: FooCo |
      | Darryl Whatshisname | +14155551221 | 210    | name: FooCo |

  Scenario: User gets pages of rankings
    When "+14155551212" sends SMS "rankings"
    And "+14155551212" sends SMS "morerankings"
    Then "+14155551212" should have received an SMS "Phil Darnowsky (250)\nVlad Gyster (238)\nDan Croak (237)\nTony Wu (237)\nKelli Peterson (225)\nPeggy Bartek (220)\nMaryLynne Karman (219)\nSend MORERANKINGS for more."
    And "+14155551212" should have received an SMS "Kristina Rikantis (218)\nKirill Bernshteyn (215)\nDarryl Whatshisname (210)\nAudrey Roth (205)\nSend MORERANKINGS for more."

  Scenario: User asks for more rankings without having gotten any yet
    When "+14155551212" sends SMS "morerankings"
    And "+14155551212" sends SMS "morerankings"
    Then "+14155551212" should have received an SMS "Phil Darnowsky (250)\nVlad Gyster (238)\nDan Croak (237)\nTony Wu (237)\nKelli Peterson (225)\nPeggy Bartek (220)\nMaryLynne Karman (219)\nSend MORERANKINGS for more."
    And "+14155551212" should have received an SMS "Kristina Rikantis (218)\nKirill Bernshteyn (215)\nDarryl Whatshisname (210)\nAudrey Roth (205)\nSend MORERANKINGS for more."

  Scenario: User comes to end of rankings
    Given "Phil Darnowsky" has ranking query offset 10
    And "+14155551212" sends SMS "morerankings"
    And "+14155551212" sends SMS "morerankings"
    And "+14155551212" sends SMS "morerankings"
    Then "+14155551212" should have received SMS "Audrey Roth (205)\nSend MORERANKINGS for more."
    And "+14155551212" should have received SMS "That's everybody! Send RANKINGS to start over from the top."
    Then "+14155551212" should have received an SMS "Phil Darnowsky (250)\nVlad Gyster (238)\nDan Croak (237)\nTony Wu (237)\nKelli Peterson (225)\nPeggy Bartek (220)\nMaryLynne Karman (219)\nSend MORERANKINGS for more."

  Scenario: RANKINGS resets query offset
    Given "Phil Darnowsky" has ranking query offset 10
    And "+14155551212" sends SMS "rankings"
    And "+14155551212" sends SMS "morerankings"
    Then "+14155551212" should have received an SMS "Phil Darnowsky (250)\nVlad Gyster (238)\nDan Croak (237)\nTony Wu (237)\nKelli Peterson (225)\nPeggy Bartek (220)\nMaryLynne Karman (219)\nSend MORERANKINGS for more."
    And "+14155551212" should have received an SMS "Kristina Rikantis (218)\nKirill Bernshteyn (215)\nDarryl Whatshisname (210)\nAudrey Roth (205)\nSend MORERANKINGS for more."

  Scenario: Responses should abbreviate themselves if they would go over 160 characters
    Given the following claimed users exist:
      | name                | points | phone number | demo                |
      | Balaji Paladugu     | 256    | +16175551212 | name: BarCo |
      | Daryl Kurtz         | 198    | +16175551213 | name: BarCo |
      | Kristian Burch      | 187    | +16175551214 | name: BarCo |
      | Michael Vidalez     | 102    | +16175551215 | name: BarCo |
      | Ryan Booth          | 90     | +16175551216 | name: BarCo |
      | Sabrina DeVeny      | 88     | +16175551217 | name: BarCo |
      | Lucius McGillicuddy | 33     | +19001231234 | name: BarCo |
    And "+16175551212" sends SMS "rankings"
    Then "+16175551212" should not have received an SMS including "Lucius McGillicuddy"
    When "+16175551212" sends SMS "morerankings"
    Then "+16175551212" should have received an SMS including "Lucius McGillicuddy"
