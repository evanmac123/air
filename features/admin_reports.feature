Feature: Admin can view reports

  Background:
    Given the following demos exist:
      | name       | 
      | January    |
      | February   |
      | Some Other |
    Given the following users exist:
      | name      | demo             | points | is_site_admin |
      | George    | name: January    | 9      | false         |
      | Lofty     | name: January    | 10     | false         |
      | General   | name: January    | 11     | false         |
      | Soprano   | name: February   | 102    | false         |
      | Harrison  | name: February   | 3      | false         |
      | admin     | name: Some Other | 0      | true          |
    Given the following rules exist:
      | description      | demo           |
      | flew fast        | name: January  |
      | drove nice       | name: January  |
      | walked tall      | name: February |
      | skated cold      | name: February |
    Given the following rule values exists:
      | value  | rule                     | is_primary | 
      | flew   | description: flew fast   | true       |
      | drove  | description: drove nice  | true       |
      | walked | description: walked tall | true       |
      | skated | description: skated cold | true       |
    Given the following act with rule exist:
      | user         | inherent_points | rule                   |
      | name: George | 0               | description: flew fast |
    Given the following levels exist: 
      | demo            | name           | threshold  |
      | name: January   | level one      | 10         |
      | name: January   | level two      | 20         |
      | name: January   | level three    | 50         |
      | name: February  | level one      | 13         |
    Given the following tag exists:
      | name      |
      | longevity |
    Given the following label exists:
      | tag             | rule              |
      | name: longevity | description: flew |
    Given "admin" has password "foobar"
    And I sign in via the login page as "admin/foobar"
  
  Scenario: I can view the points report
    And I go to the admin reports page for "January"
    And I follow "Points"
    Then I should see "January"
    And I should see the following table:
      | Points Achieved |	Number Users | Percent Users |
      | 11-20           |	1            | 33.3%         |
      | 0-10            |	2            | 66.7%         |
    
  Scenario: I can view the levels reports
    And I go to the admin reports page for "January"
    And I follow "Levels"
    Then I should see "January"
    And I should see the following table:
    	|   | Current Level           |	Points Range | # Users |	% Users |
      | 4 | level three             | 50+          | 0       | 0.0%     |
      | 3 | level two               | 20-49        | 0       | 0.0%     |
      | 2 | level one               | 10-19        | 2       | 66.7%    |
      | 1 | 1                       | 0-9          | 1       | 33.3%    |


  Scenario: I can view the interaction popularity report
    And I go to the admin reports page for "January"
    And I follow "Interactions"
    Then I should see "January"
    And show me the page
    And I should see the following table:
      | Interaction |	# Completed |	% Completed |
      | drove       |	0           |	0.0%        |
      | flew        |	1           |	33.3%       |
    And I should see the following table:
       | Interactions Completed | # Users | % Users |
       | 2                      |	0       |	0.0%    |
       | 1                      |	1       |	33.3%   |
       | 0                      |	2       | 66.7%   |
 


  

    

    
  