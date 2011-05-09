Feature: Admin adds and edits rules

  Background:
    Given the following demo exists:
      | company name             |
      | Applied Awesomeness Inc. |
    And I sign in via the login page

  Scenario: Admin adds a rule
    When I go to the admin rules page for "Applied Awesomeness Inc."
    And I fill in the following:
      | Value           | Made toast                         |
      | Points          | 100                                |
      | Reply           | 100 points! Toast is the God Food! |
      | Description     | Made the God Food                  |
      | Alltime limit   | 1                                  |
      | Referral points | 10                                 |
    And I uncheck "Suggestible"
    And I press "Create Rules"
    Then I should see the following rule:
      | value      | points | reply                              | description       | all time limit | referral points | suggestible |
      | made toast | 100    | 100 points! Toast is the God Food! | Made the God Food | 1              | 10              | false       |

  Scenario: Admin sees existing rules
    Given the following rules exist:
      | value      | points | reply            | description                  | alltime limit | referral points   | suggestible | demo                                   |
      | ate kitten | 100000 | Eat that kitten! | ate the hell out of a kitten | 5             | 500               | true        | company_name: Applied Awesomeness Inc. |
      | ate fruit  | 5      | Ate boring fruit | ate fruit, yawn              |               |                   | false       | company_name: Applied Awesomeness Inc. |
    When I go to the admin rules page for "Applied Awesomeness Inc."
    Then I should see the following rules:
      | value      | points | reply            | description                  | alltime limit | referral points   | suggestible |
      | ate kitten | 100000 | Eat that kitten! | ate the hell out of a kitten | 5             | 500               | true        |
      | ate fruit  | 5      | Ate boring fruit | ate fruit, yawn              |               |                   | false       |

  Scenario: Admin uploads rules in bulk
    When I go to the admin rules page for "Applied Awesomeness Inc."
    And I attach the file "features/support/fixtures/rule_bulk_upload/simple_loaded_rules.csv" to "Bulk rules CSV"
    And I press "Upload Rules"
    Then I should see the following rules in a form:
      | value      | points | reply            | description                  | alltime limit | referral points   | suggestible |
      | ate kitten | 100000 | Eat that kitten! | ate the hell out of a kitten | 5             | 500               | true        |
      | ate fruit  | 5      | Ate boring fruit | ate fruit, yawn              |               |                   | false       |

  Scenario: Bulk upload including rule value that already exists (up to case) notes that rule will be updated
    Given the following rules exist:
      | value      | demo                                   |
      | ate kitten | company_name: Applied Awesomeness Inc. |
    When I go to the admin rules page for "Applied Awesomeness Inc."
    And I attach the file "features/support/fixtures/rule_bulk_upload/duplicate_existing_rule.csv" to "Bulk rules CSV"
    And I press "Upload Rules"
    Then I should see the following rules in a form:
      | value      | points | reply            | description                  | alltime limit | referral points   | suggestible |
      | Ate Kitten | 100000 | Eat that kitten! | ate the hell out of a kitten | 5             | 500               | true        |
    And I should see "A rule with this value already exists. If you add this rule, the existing rule will be overwritten. Which might be what you want."

  Scenario: Bulk upload ignores duplicate rules in other demos
    Given the following rules exist:
      | value      | demo                                |
      | ate kitten | company_name: Extreme Lameness Ltd. |
    When I go to the admin rules page for "Applied Awesomeness Inc."
    And I attach the file "features/support/fixtures/rule_bulk_upload/duplicate_existing_rule.csv" to "Bulk rules CSV"
    And I press "Upload Rules"
    Then I should see the following rules in a form:
      | value      | points | reply            | description                  | alltime limit | referral points   | suggestible |
      | Ate Kitten | 100000 | Eat that kitten! | ate the hell out of a kitten | 5             | 500               | true        |
    And I should not see "A rule with this value already exists. If you add this rule, the existing rule will be overwritten. Which might be what you want."
    
  Scenario: Bulk upload can live with the kind of weird-ass CSVs that Vlad's machine generates
    When I go to the admin rules page for "Applied Awesomeness Inc."
    And I attach the file "features/support/fixtures/rule_bulk_upload/weird_ass_csv_from_vlad.csv" to "Bulk rules CSV"
    And I press "Upload Rules"
    Then I should see the following rules in a form:
      | value      | points | reply                                        | description                                                    | alltime limit | referral points   | suggestible |
      | Aerobics   | 7      | Working up a sweat!                          | I did aerobics. Working up a sweat.                            |               | 4                 | true        |
      | Archery    | 4      | Bulls-eye!                                   | I did archery. Bulls-eye!                                      |               | 2                 | true        |
      | Badminton  | 4      | You put the BAD in Badminton. In a good way. | I played badminton. I put the BAD in Badminton. In a good way. |               | 2                 | true        |
    And I should not see a rule with the value "value" in a form

  Scenario: Admin edits rules
    Given the following rule exists:
      | value      | points | reply            | description                  | alltime limit | referral points   | suggestible | demo                                   |
      | ate kitten | 100000 | Eat that kitten! | ate the hell out of a kitten | 5             | 500               | true        | company_name: Applied Awesomeness Inc. |
    When I go to the admin rules page for "Applied Awesomeness Inc."
    And I follow "Edit Rule"
    Then I should see the following rules in a form:
      | value      | points | reply            | description                  | alltime limit | referral points   | suggestible | 
      | ate kitten | 100000 | Eat that kitten! | ate the hell out of a kitten | 5             | 500               | true        |

  Scenario: Admin updates rules
    Given the following rule exists:
      | value      | points | demo                                   |
      | ate kitten | 500    | company_name: Applied Awesomeness Inc. |
    When I go to the admin rules page for "Applied Awesomeness Inc."
    And I attach the file "features/support/fixtures/rule_bulk_upload/simple_loaded_rules.csv" to "Bulk rules CSV"
    And I press "Upload Rules"
    And I press "Create Rules"      
    Then I should see the following rules:
      | value      | points | reply                              | description       | all time limit | referral points | suggestible |
      | ate kitten | 100000 | Eat that kitten! | ate the hell out of a kitten | 5             | 500               | true        |
      | ate fruit  | 5      | Ate boring fruit | ate fruit, yawn              |               |                   | false       |
