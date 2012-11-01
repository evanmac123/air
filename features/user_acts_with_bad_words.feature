Feature: Bad words get dropped unceremoniously

  Background:
    Given the following claimed users exist:
      | phone number | demo           |
      | +14155551212 | name: PrudeCo  |
      | +16175551212 | name: WhatevCo |
    And the following bad word exists:
      | value | demo          |
      | shit  |               |
      | heck  | name: PrudeCo |

  Scenario: User uses generic bad word
    When "+14155551212" sends SMS "ate shit"
    Then "+14155551212" should have received an SMS including "Sorry, we don't give points for that."
    But "+14155551212" should not have received an SMS including `Text "s" to suggest we add it.`

  Scenario: User uses demo-specific bad word
    When "+14155551212" sends SMS "oh heck"
    Then "+14155551212" should have received an SMS including "Sorry, we don't give points for that."
    But "+14155551212" should not have received an SMS including `Text "s" to suggest we add it.`

    When "+16175551212" sends SMS "oh heck"
    Then "+16175551212" should have received an SMS `Sorry, I don't understand what "oh heck" means. Text "s" to suggest we add it.`
