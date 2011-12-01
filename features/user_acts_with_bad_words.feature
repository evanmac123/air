Feature: Bad words get dropped unceremoniously

  Background:
    Given the following users exist:
      | phone number | demo                   |
      | +14155551212 | company_name: PrudeCo  |
      | +16175551212 | company_name: WhatevCo |
    And the following bad word exists:
      | value | demo                  |
      | shit  |                       |
      | heck  | company_name: PrudeCo |

  Scenario: User uses generic bad word
    When "+14155551212" sends SMS "ate shit"
    Then "+14155551212" should have received an SMS including "Sorry, I don't understand what that means"
    But "+14155551212" should not have received an SMS including `Text "s" to suggest we add what you sent.`

  Scenario: User uses demo-specific bad word
    When "+14155551212" sends SMS "oh heck"
    Then "+14155551212" should have received an SMS including "Sorry, I don't understand what that means"
    But "+14155551212" should not have received an SMS including `Text "s" to suggest we add what you sent.`

    When "+16175551212" sends SMS "oh heck"
    Then "+16175551212" should have received an SMS `Sorry, I don't understand what that means. Text "s" to suggest we add what you sent.`
