Feature: User gives credit to game referer via autocomplete field

  Background:
    Given the following demo exists:
      | company_name |
      | Bratwurst    |
      | Gleason    |
    Given the following self inviting domain exists:
      | domain     | demo                    |
      | hopper.com | company_name: Bratwurst |
      | biker.com  | company_name: Gleason   |

    Given the following users exist:
      | name               | demo                    | email        | slug      | sms_slug    |
      | Charlie Brainfield | company_name: Bratwurst | 2@hopper.com | airplane  | airplane    |
      | Yo Yo Ma           | company_name: Bratwurst | 3@hopper.com | naked     | naked       |
      | Threefold          | company_name: Bratwurst | 4@hopper.com | eraser    | eraser      |
      | Watermelon         | company_name: Gleason   | 1@biker.com  | jumper    | jumper      |
      | Bruce Springsteen  | company_name: Gleason   | 2@biker.com  | airairair | airairair   |
      | Barnaby Watson     | company_name: Gleason   | 3@biker.com  | mypeeps   | mypeeps     |
      | Charlie Moore      | company_name: Gleason   | 4@biker.com  | livingit  | livingit    |
    Given the following claimed user exists:
      | name               | demo                    | email              | slug      | sms_slug    |
      | Barnaby    | company_name: Bratwcc  urst | claimed@hopper.com | smoke     | smoke       |    
    
    Given "Barnaby" has the password "foo"
    Given I sign in via the login page as "Barnaby/foo"
  
  Scenario:
    Then I should see "Invite your friends"
    