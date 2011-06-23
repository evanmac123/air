Feature: Admin adds and edits rules

  Background:
    Given the following demo exists:
      | company name |
      | FooCorp      |
    And I sign in via the login page
    And the following rules exist:
      | points | reply   | description      | alltime limit | referral points | suggestible | demo                  |
      | 12     | banana  | I ate a banana   | 15            | 10              | true        | company_name: FooCorp |
      | 6      | kitten  | I ate a kitten   | 4             | 5               | true        | company_name: FooCorp |
      | 18     | jogging | I went jogging   | 666           | 44              | true        |                       |
      | 30     | weights | I lifted weights | 14            | 79              | true        |                       |
    And the following rule values exist:
      | value          | is_primary | rule           |
      | ate banana     | true       | reply: banana  |
      | bananaed up    | false      | reply: banana  |
      | got banana-ey  | false      | reply: banana  |
      | ate kitten     | true       | reply: kitten  |
      | ate kitty      | false      | reply: kitten  |
      | ate kittycat   | false      | reply: kitten  |
      | went jogging   | true       | reply: jogging |
      | did jogging    | false      | reply: jogging |
      | went for a jog | false      | reply: jogging |
      | lifted weights | true       | reply: weights |

  Scenario: Admin sees existing rules in current demo
    When I go to the admin rules page for "FooCorp"
    Then I should see all existing rules for FooCorp

  Scenario: Admin edits all rule values
    When I go to the rule edit page for "ate banana"
    And I replace "bananaed up" with "consumed banana"
    And I replace "got banana-ey" with "ate me a banana"
    And I press "Update Rule"
    Then I should be on the admin rules page for "FooCorp"
    And I should see the following rule:
      | primary_value | secondary_values                | points | reply  | description    | alltime_limit | referral_points | suggestible |
      | ate banana    | ate me a banana,consumed banana | 12     | banana | I ate a banana | 15            | 10              | true        |

  Scenario: Admin edits some but not all values for a rule
    When I go to the rule edit page for "ate banana"
    And I replace "got banana-ey" with "ate me a banana"
    And I press "Update Rule"
    Then I should be on the admin rules page for "FooCorp"
    And I should see the following rule:
      | primary_value | secondary_values            | points | reply  | description    | alltime_limit | referral_points | suggestible |
      | ate banana    | ate me a banana,bananaed up | 12     | banana | I ate a banana | 15            | 10              | true        |

  Scenario: Admin deletes rule value by blanking it out
    When I go to the rule edit page for "ate banana"
    And I replace "got banana-ey" with ""
    And I press "Update Rule"
    Then I should be on the admin rules page for "FooCorp"
    And I should see the following rule:
      | primary_value | secondary_values | points | reply  | description    | alltime_limit | referral_points | suggestible |
      | ate banana    | bananaed up      | 12     | banana | I ate a banana | 15            | 10              | true        |

  Scenario: Admin tries to delete primary value from a rule by blanking it out
    When I go to the rule edit page for "ate banana"
    And I fill in the following:
      | Primary value |                      |
      | Description   | Consumed bananaflesh |
    And I press "Update Rule"
    Then I should be on the rule edit page for "ate banana"
    And I should see "You can't blank out the primary value of a rule"

  Scenario: Admin edits properties of a rule
    When I go to the rule edit page for "ate banana"
    And I fill in the following:
      | Primary value   | ate bananafruit                    |
      | Points          | 100                                |
      | Reply           | 100 points! Toast is the God Food! |
      | Description     | Made the God Food                  |
      | Alltime limit   | 1                                  |
      | Referral points | 10                                 |
    And I uncheck "Suggestible"
    And I press "Update Rule"
    Then I should be on the admin rules page for "FooCorp"
    And I should see the following rule:
      | primary_value      | secondary_values          | points | reply                              | description       | alltime_limit | referral_points | suggestible |
      | ate bananafruit    | bananaed up,got banana-ey | 100    | 100 points! Toast is the God Food! | Made the God Food | 1             | 10              | false       |

  Scenario: Admin can see standard rulebook rules
    When I go to the admin rules page for the standard rulebook 
    Then I should see all the standard rulebook rules

  Scenario: Admin can edit standard rulebook rules
    When I go to the rule edit page for "went jogging"
    And I fill in the following:
      | Primary value   | ate bananafruit                    |
      | Points          | 100                                |
      | Reply           | 100 points! Toast is the God Food! |
      | Description     | Made the God Food                  |
      | Alltime limit   | 1                                  |
      | Referral points | 10                                 |
    And I uncheck "Suggestible"
    And I replace "did jogging" with "bananaed up"
    And I replace "went for a jog" with "got banana-ey"
    And I press "Update Rule"
    Then I should be on the admin rules page for the standard rulebook
    And I should see the following rule:
      | primary_value      | secondary_values          | points | reply                              | description       | alltime_limit | referral_points | suggestible |
      | ate bananafruit    | bananaed up,got banana-ey | 100    | 100 points! Toast is the God Food! | Made the God Food | 1             | 10              | false       |

  Scenario: Admin can add a single rule to demo
    When I go to the admin rules page for "FooCorp"
    And I follow "Add new rule"
    And I fill in the following:
      | Primary value   | ate oatmeal                     |
      | Points          | 55                              |
      | Reply           | 55 points for you, bucko.       |
      | Description     | I ate a big ol bowl of oatmeal. |
      | Alltime limit   | 5                               |
      | Referral points | 19                              |
    And I uncheck "Suggestible"
    And I fill in secondary value field #1 with "ate some oatmeal"
    And I press "Create Rule"
    Then I should be on the admin rules page for "FooCorp"
    And I should see the following rule:
      | primary_value | secondary_values | points | reply                     | description                    | alltime_limit | referral_points | suggestible |
      | ate oatmeal   | ate some oatmeal | 55     | 55 points for you, bucko. | I ate a big ol bowl of oatmeal | 5             | 19              | false       |

  Scenario: Admin can add a single rule to standard playbook
    When I go to the admin rules page for the standard playbook
    And I follow "Add new rule"
    And I fill in the following:
      | Primary value   | ate oatmeal                     |
      | Points          | 55                              |
      | Reply           | 55 points for you, bucko.       |
      | Description     | I ate a big ol bowl of oatmeal. |
      | Alltime limit   | 5                               |
      | Referral points | 19                              |
    And I uncheck "Suggestible"
    And I fill in secondary value field #1 with "ate some oatmeal"
    And I press "Create Rule"
    Then I should be on the admin rules page for the standard playbook
    And I should see the following rule:
      | primary_value | secondary_values | points | reply                     | description                    | alltime_limit | referral_points | suggestible |
      | ate oatmeal   | ate some oatmeal | 55     | 55 points for you, bucko. | I ate a big ol bowl of oatmeal | 5             | 19              | false       |

  Scenario: Cancel link from demo rule edit goes to proper place
    When I go to the rule edit page for "ate banana"
    And I follow "Cancel"
    Then I should be on the admin rules page for "FooCorp"
    
  Scenario: Cancel link from standard playbook rule edit goes to proper place
    When I go to the rule edit page for "went jogging"
    And I follow "Cancel"
    Then I should be on the admin rules page for the standard playbook

  Scenario: Proper restrictions on rule reply length
    When I go to the rule edit page for "ate banana"
    Then I should see a restricted text field "Reply" with length 125
