Feature: User requests an invitation via SMS

  Scenario:
    When "+14155551212" sends SMS "email@email.com"
    Then "+14155551212" should have received an SMS "An invitation has been sent to email@email.com."
