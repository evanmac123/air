Feature: Admin sets up demo

  Background:
    Given I sign in as an admin via the login page

  Scenario: Admin sets up demo
    When I go to the admin page
    When I follow "Create New Game"
    And I fill in "Name of Demo" with "3M"
    And I fill in "Victory threshold" with "100"
    And I fill in "Name of Level" with "level 1 (N00b)"
    And I fill in "Threshold" with "10"
    And I fill in "Victory verification email" with "lucille@example.com"
    And I fill in "Victory verification SMS number" with "415-867-5309"
    And I fill in "Custom welcome message" with "3M will rule you all!"
    And I fill in "Followup welcome message" with "That's right."
    And I fill in "Followup welcome message delay (in minutes)" with "30"
    And I fill in "Custom victory achievement message" with "Congratulations as of %{winning_time}!"
    And I fill in "Custom victory SMS" with "You did it with %{points} points!"
    And I fill in "Custom victory scoreboard message" with "is the person!"
    And I fill in "Starting player score" with "5"
    And I set the start time to "April/1/2013/12 PM/00"
    And I set the end time to "May/1/2015/12 PM/00"
    And I fill in "Threshold to credit user who referred you to the game (in minutes)" with "60"
    And I fill in "Bonus for referring another to the game" with "5"
    And I fill in "Bonus for crediting the user who referred you to the game" with "17"
    And I fill in "Points for connecting to another player" with "10"
    And I fill in "Prize text" with "More ice cream than you can shake a stick at."
    And I fill in "Help message" with "Get a job"
    And I fill in "Phone-number-not-recognized message" with "Go play in your own yard"
    And I fill in "Response to command before game begins" with "Hold ur horses"
    And I fill in "Response to command after game ends" with "Too slow!"
    And I fill in "Activity feed text when user answers a survey question" with "responded to an inquiry"
    And I fill in "Message user sees on login" with "La llama!"
    And I fill in "Custom example for slide 1 of tutorial" with "ran a mile"
    And I fill in "Custom example for playbox tooltip" with "smoked a joint"
    And I uncheck "Use standard playbook rules"
    And I fill in "Mute notice threshold" with "17"
    And I fill in "Client name" with "BigCorp"
    And I fill in "Custom already-claimed message" with "You're in, fool."
    And I uncheck "Send post-act summaries with act replies"
    And I fill in "Custom support reply" with "We'll call you."
    And I fill in "Internal domains" with "example.com, foo.com, bar.com"
    And I press "Create Game"
    Then I should be on the admin "3M" demo page
    And I should see "100 points to win"
    And I should see "Victory email to lucille@example.com"
    And I should see "Victory verification SMS to +14158675309"
    And I should see "Welcome message: 3M will rule you all!"
    And I should see "Followup welcome message: That's right. (send 30 minutes after invitation accepted)"
    And I should see "Victory achievement message: Congratulations as of %{winning_time}!"
    And I should see "Victory SMS: You did it with %{points} points!"
    And I should see "Victory scoreboard message: is the person!"
    And I should see "New players start with 5 points"
    And I should see "Game begins at April 01, 2013 at 12:00 PM Eastern"
    And I should see "Game ends at May 01, 2015 at 12:00 PM Eastern"
    And I should see "Levels: 2: level 1 (N00b) at 10 points"
    And I should see "Bonus for referring another user to the game: 5 points (with a 60 minute threshold)"
    And I should see "Bonus for crediting the user who referred you to the game: 17 points"
    And I should see "Points for connecting to another user: 10"
    And I should see "Game will not use standard playbook rules, only custom rules."    
    And I should see 'Prize response is "More ice cream than you can shake a stick at."'
    And I should see 'Help message is "Get a job"'
    And I should see 'Phone-number-not-recognized message is "Go play in your own yard"'
    And I should see 'Response to command before game begins is "Hold ur horses"'
    And I should see 'Response to command after game ends is "Too slow!"'
    And I should see 'Activity feed text when user answers a survey question is "responded to an inquiry"'
    And I should see 'Message user sees on login is "La llama!"'
    And I should see "ran a mile"
    And I should see "smoked a joint"
    And I should see "Mute notice to users after 17 SMSes"
    And I should see "Client name is BigCorp"
    And I should see `Custom already-claimed message is "You're in, fool."`
    And I should see "No post-act summaries will be sent"
    And I should see `Custom support reply is "We'll call you."`
    And I should see "Internal email domains are: example.com foo.com bar.com"

  Scenario: Correct defaults
    Given I am on the admin page
    When I follow "Create New Game"
    And I fill in "Name of Demo" with "3M"
    And I press "Create Game"
    Then I should see "Welcome message: You've joined the %{name} game! @{reply here}"
    And I should see "Victory achievement message: You won on %{winning_time}. Congratulations!"
    And I should see "Victory SMS: Congratulations! You've got %{points} points and have qualified for the drawing!"
    And I should see "Victory scoreboard message: Won game!"
    And I should see "New players start with 0 points"
    And I should not see "points to win"
    And I should not see "Victory email to"
    And I should not see "Victory verification SMS to"
    And I should see "Game began immediately upon creation"
    And I should see "Game goes on indefinitely"
    And I should see "No levels"
    And I should see "No followup message"
    And I should see "No bonus for referring another user to the game"
    And I should see "No bonus for crediting the user who referred you to the game"
    And I should see "No points for connecting to another user"
    And I should see "Game will use standard playbook rules as well as custom rules."
    And I should see "Game will have default response about prizes (indicating no prize)"
    And I should see "Game will have default help message"
    And I should see "Game will have default phone-number-not-recognized message"
    And I should see 'Game will have default response to command before game begins.'
    And I should see 'Game will have default response to command after game ends.'
    And I should see 'Game will have default activity feed text when user answers a survey question'
    And I should see "Game will have default mute notice threshold"
    And I should see "User sees no custom message on login"
    And I should see "No client name set"
    And I should see "Game will have default already-claimed message"
    And I should see "Post-act summaries will be sent"
    And I should see "No custom support reply"
    And I should see "No email domains will be considered internal"

  Scenario: Appropriate restrictions on text that gets SMSed
    Given I am on the admin page
    When I follow "Create New Game"
    Then I should see a restricted text field "Custom welcome message"
    And I should see a restricted text field "Custom victory SMS"
    And I should see a restricted text field "Followup welcome message"
    And I should see a restricted text field "Name of Level" with length 140

  Scenario: Admin adds user
    Given a demo exists with a name of "3M"
    And I am on the admin "3M" demo page
    When I follow "Add new user"
    And I fill in "Name" with "Bobby Jones"
    And I fill in "Email" with "bobby@example.com"
    And I press "Submit"
    Then I should be on the admin "3M" demo page
    When I follow "B"
    Then I should see "Bobby Jones"
