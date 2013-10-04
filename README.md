H.Engage
========

Information about the H.Engage Rails app

Laptop setup
------------

### Mac
[Thoughtbot Laptop](https://github.com/thoughtbot/laptop) is a script to set up a Mac OS X laptop for Rails development.

Many Mac users use [Textmate](http://macromates.com/) to write their code.
If you use Textmate, set your tabs to "Soft Tabs: 2". This is one of the drop-down options at the very bottom of your window.

### (We Don't Do) Windows

### Linux
The following instructions are for an Ubuntu system; some slight modifications may need to be made for other distributions.

#### Install the following packages
1. build-essential
1. git
1. postgresql
1. mongodb
1. libqtwebkit-dev
1. libpq-dev
1. nodejs
1. ImageMagick
1. pgadmin3 (Optional: PostgreSQL GUI admin tool)
1. curl (Optional: If using RVM - see below)

Since the _Package Manager_ is used to install these packages they might not be as up-to-date as needed. 
If this is the case you will need to go to the appropriate site to get the latest and greatest version.

#### Git
Run the following commands:

    git config --global user.name "Joe Blow"
    git config --global user.email "joe@hengage.com"

#### PostgreSQL

Phil put it pretty well, so might as well quote him:

> Getting Postgres authorization set up can be somewhat confusing and frustrating. 
> So, in the best tradition of programmers everywhere, we're going to cheat. 
> I've included a file called *pg_hba.conf* which configures authorization for Postgres: 
> you should be able to just drop this in place once you have Postgres installed, overwriting the default one. 
>
> What the settings in this file basically say is "*Anyone on the local machine is allowed to access any database; 
> nobody from outside the local machine is allowed to access any database.*" 
> This would be sketchy for a production machine, but it's perfect for development.

So get `pg_hba.conf` from Phil and drop it into `/etc/postgresql/9.1/main/` (version number might be different)

Then you'll need to create a database user (Postgres keeps its own lists of users separate from the system's) to use:

    $ sudo su postgres
    $ createuser joe # this should be the same as your system username

It will ask if the new user should be a superuser: say yes. Again, this is fine for a development machine but not a production server.

#### Ruby Version Manager (RVM)
Additional packages need to be installed when using RVM with (MRI) Ruby. Enter this command to see the list: `rvm requirements`

We use MRI Ruby 1.9.2 => Run this command: `rvm install 1.9.2`

Create an _hengage_ gemset and make it the default:

    joe@hengage:~$ rvm gemset create hengage
    gemset created hengage    => /home/joe/.rvm/gems/ruby-1.9.2-p320@hengage
    joe@hengage:~$ rvm use ruby-1.9.2-p320@hengage --default
    Using /home/joe/.rvm/gems/ruby-1.9.2-p320 with gemset hengage
    joe@hengage:~$ rvm current
    ruby-1.9.2-p320@hengage


Aliases for faster workflow
---------------------------

Git aliases: add to ~/.gitconfig

    [alias]
      up = !git fetch origin && git rebase origin/master
      mm = !test `git rev-parse master` = $(git merge-base HEAD master) && git checkout master && git merge HEAD@{1} || echo "Non-fastforward"

Shell aliases: add to ~/.aliases

    alias be="bundle exec"
    alias s="bundle exec rspec"
    alias cuc="bundle exec cucumber"

 * For the aliases to take effect, add this to your ~/.bash_profile:

    if [ -e "$HOME/.aliases" ]; then
      source "$HOME/.aliases"
    fi
    
Getting dependencies
--------------------

Download Qt:

    http://get.qt.nokia.com/qt/source/qt-mac-opensource-4.7.3.dmg

To make life easier, install a few Ruby gems:

    gem install heroku bundler git_remote_branch

Setting up the app itself
-------------------------

Get the H.Engage source code:

    git clone git@github.com:vladig17/hengage.git

Install the dependent Ruby libraries:

    bundle

Create your development and test databases. (Note: Two distinct steps: 1 for development and 1 for test):

    rake db:create

Migrate the development database:

    rake db:migrate

Prepare the test database:

    rake db:test:prepare
    
You need to create one user before firing up the app, so after you've cloned the repository and got everything
else set up, fire up a Rails console and create a (claimed, admin) user thusly (password must have at least 6 characters):

    user = FactoryGirl.build :user, :claimed, name: 'Joe Blow', password: 'joeblow', password_confirmation: 'joeblow', email: 'joe@blow.com', is_site_admin: true
    user.save
    
Staging and production environments
-----------------------------------

We're using Heroku as a hosting provider. Deploying to Heroku is done via git. So, set up your git remotes for each environment:

    git remote add staging git@heroku.com:hengage-staging.git
    git remote add production git@heroku.com:hengage.git

Development process
-------------------

    git pull --rebase
    grb create feature-branch
    be rake

This creates a new branch for your feature. Name it something relevant. Run the tests to make sure everything's passing. Then, implement the feature.

    be rake
    git add -A
    git commit -m "my awesome feature"
    git push origin feature-branch
    
Open up the Github repo, change into your feature-branch branch. Press the "Pull request" button. It should automatically choose the commits that are different between master and your feature-branch. Create a pull request and share the link in Campfire with the team. When someone else gives you the thumbs-up, you can merge into master:

    git up
    git mm
    git push origin master

Running the app
---------------

To run the app locally:

    rails s
    
Running the tests
-----------------

To run the whole suite:

    be rake

To run an individual spec file:

    s spec/models/user_spec.rb
    
To run an individual Cucumber file:

    cuc features/admin_adds_rules.feature

Deploying
---------

To deploy to staging:

    be rake deploy:staging

To deploy to production:

    be rake deploy:production

Using these commands is important because they will migrate the database and notify Hoptoad of the deploy.

Heroku
------

To access data on Heroku:

    heroku console --remote staging
    heroku console --remote production

This will drop you into a Rails console for either environment. You can run ActiveRecord queries from there.

To dump staging or production data into your development environment:

    heroku db:pull --remote staging
    heroku db:pull --remote production

We can create a database backup at any time:

    heroku pgbackups:capture --remote production

View database backups:

    heroku pgbackups --remote production

To destroy a backup:

    heroku pgbackups:destroy b003 --remote production

Transfer production data to staging:

    heroku pgbackups:capture --remote production
    heroku pgbackups:restore DATABASE `heroku pgbackups:url --remote production` --remote staging
    
Miscellaneous Things That I Just Want To Get Up Here On A Friday Night
----------------------------------------------------------------------
SOFTWARE NEEDED TO RUN OUR APP
Start Redis Server: redis-server /etc/redis.conf
MongoDB URI: mongodb://127.0.0.1:27017/health_development

HEROKU AND TWILIO STATUS
http://status.twilio.com/
https://status.heroku.com/

FETCH DATA FOR THE K'S
https://dataclips.heroku.com/

PUSH TOPIC BRANCH TO GITHUB
git push origin your-topic-branch

DEPLOY TO PRODUCTION WITH MIGRATIONS
* Good idea to do a 'restart' after run migration. (Done automatically after pushing.)
git push production master
heroku run rake db:migrate -a hengage
heroku restart -a hengage

FORCE A PUSH TO STAGING AND THEN RUN MIGRATIONS
git push -f staging your-topic-branch:master
heroku run rake db:migrate -a hengage-staging
heroku restart -a hengage-staging

ROLL BACK A DEPLOYMENT
phil@rutger:~$ heroku rollback -a hengage-staging
Rolling back hengage-staging... done, v1001
! Warning: rollback affects code and config vars; it doesn't add or remove addons. To undo, run: heroku rollback v1002
phil@rutger:~$ # If you have migrations, roll them back first!
phil@rutger:~$ # heroku run rake db:rollback STEP=3 # for example

START A RAILS CONSOLE ON HEROKU
heroku run console -a hengage
heroku run console -a hengage-staging

TAIL HEROKU LOG FILES
heroku logs --tail -a hengage
heroku logs --tail -a hengage-staging

INTERACT WITH NUMBER OF APP SERVERS AND DELAYED JOBS
phil@rutger:~$ heroku ps -a hengage
=== web (1X): `bundle exec unicorn -p $PORT `
web.1: up 2013/09/23 16:19:09 (~ 26m ago)
web.2: up 2013/09/23 16:19:13 (~ 26m ago)
:	:	:	:	:	:	:	:	:	
web.44: up 2013/09/23 16:19:23 (~ 26m ago)
web.45: up 2013/09/23 16:19:09 (~ 26m ago)

=== worker (1X): `bundle exec rake jobs:work`
worker.1: up 2013/09/23 16:19:09 (~ 26m ago)
worker.2: up 2013/09/23 16:19:10 (~ 26m ago)
worker.3: up 2013/09/23 16:19:12 (~ 26m ago)
worker.4: up 2013/09/23 16:19:12 (~ 26m ago)
worker.5: up 2013/09/23 16:19:09 (~ 26m ago)

phil@rutger:~$ heroku help ps:scale
Usage: heroku ps:scale DYNO1=AMOUNT1 [DYNO2=AMOUNT2 ...]

Scale dynos by the given amount
Examples:
$ heroku ps:scale web=3 worker+1
Scaling web dynos... done, now running 3
Scaling worker dynos... done, now running 1

SET ENVIRONMENT VARIABLES FOR HEROKU (PROD AND STAGING)
heroku help config:add
heroku config:set EMAIL_PROTOCOL=https -a hengage
heroku config:set EMAIL_PROTOCOL=https -a hengage-staging

SPECIFY A CRON JOB TO BE RUN ON HEROKU
Add job to: /lib/tasks/cron.rake
Will be run on a daily basis around 1am
To run now: heroku run “rake cron” -a hengage

BACKUP DATABASE
heroku help pgbackups
heroku pgbackups:capture -a hengage

* Don't specify DATABASE => Will back up production
* Takes a few minutes (Backs up to Amazon S3)
* cyan = main database ; olive = slave database
* backup_id will appear on left-side of console
* Actual console session...
phil@rutger:~$ heroku help pgbackups
Usage: heroku pgbackups
list captured backups
Additional commands, type "heroku help COMMAND" for more details:
pgbackups:capture [DATABASE] # capture a backup from a database id
pgbackups:destroy BACKUP_ID # destroys a backup
pgbackups:restore [<DATABASE> [BACKUP_ID|BACKUP_URL]] # restore a backup to a database
pgbackups:url [BACKUP_ID] # get a temporary URL for a backup

phil@rutger:~$ heroku pgbackups:capture -a hengage-staging
HEROKU_POSTGRESQL_CHARCOAL_URL (DATABASE_URL) ----backup---> b533

Pending... -^C ! Command cancelled.
phil@rutger:~$ heroku pgbackups:capture -a hengage

HEROKU_POSTGRESQL_CYAN_URL (DATABASE_URL) ----backup---> error

! must delete a backup before creating a new one
phil@rutger:~$ # To do that:
phil@rutger:~$ heroku pgbackups:capture -e -a hengage^C
phil@rutger:~$ # To restore the staging backup above (if we'd actually finished it):
phil@rutger:~$ heroku pgbackups:restore b533 -a hengage-staging
^C ! Command cancelled.
phil@rutger:~$ heroku pgbackups:url b533 -a hengage-staging
"https://s3.amazonaws.com/hkpgbackups/app3727999@heroku.com/b533.dump?AWSAccessKeyId=AKIAJSFW5453GUTHFHKA&Expires=1379970584&Signature=ggO7vN2ypaCWSb3j%2BWvkvPr3X4g%3D"
phil@rutger:~$ wget "https://s3.amazonaws.com/hkpgbackups/app3727999@heroku.com/b533.dump?AWSAccessKeyId=AKIAJSFW5453GUTHFHKA&Expires=1379970584&Signature=ggO7vN2ypaCWSb3j%2BWvkvPr3X4g%3D"
--2013-09-23 17:00:06-- https://s3.amazonaws.com/hkpgbackups/app3727999@heroku.com/b533.dump?AWSAccessKeyId=AKIAJSFW5453GUTHFHKA&Expires=1379970584&Signature=ggO7vN2ypaCWSb3j%2BWvkvPr3X4g%3D
Resolving s3.amazonaws.com (s3.amazonaws.com)... 205.251.242.195
Connecting to s3.amazonaws.com (s3.amazonaws.com)|205.251.242.195|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 118116147 (113M) [binary/octet-stream]
Saving to: `b533.dump?AWSAccessKeyId=AKIAJSFW5453GUTHFHKA&Expires=1379970584&Signature=ggO7vN2ypaCWSb3j+WvkvPr3X4g='

8% [==> ] 9,494,637 230K/s eta 5m 15s ^C
phil@rutger:~$ rm b533.dump\?AWSAccessKeyId\=AKIAJSFW5453GUTHFHKA\&Expires\=1379970584\&Signature\=ggO7vN2ypaCWSb3j+WvkvPr3X4g\=

TO CLAIM A USER
user.update_attributes accepted_invitation_at: Time.now

RUN SPECS FROM COMMAND LINE
  rvm current  (ruby-1.9.3-p194 => wrong)
  rvm use ruby-1.9.3-p194@hengage
  rvm current  (ruby-1.9.3-p194@hengage => correct)
ONE TEST 
  bundle exec rspec
  spec/acceptance/client_admin/tile_manager_spec.rb
ALL TESTS 
  bundle exec rake spec

AMAZON S3
http://aws.amazon.com/
My Account > AWS Management Console > S3

UPLOAD A LOGO FOR A DEMO TO S3
Create bucket for logo image, e.g. heinekin_logo
Set details > set permissions > make everything public
Upload image file to bucket
Right-click > properties > URL > open link in new tab
Create a Skin object for the demo and set its logo_url:

TO CREATE A CHARACTERISTIC FOR TAGGING USERS
Site Admin > Select Game > Characteristics for this demo >
Name: 'Tag Name'
Description: 'Tag Description'
Datatype: Discrete
Value: 'yes'

Example request and response:
Hey Phil,
Here are the first of 2 weekly data requests for the current Fuji round.
Can you please tag all users who did ALL of the following rules with the tag "September HCR week 1 surprise prize winners":
NEXT YEAR
AMERICAN
OCTOBER 1
Thanks,
Kate

irb(main):002:0> ActiveRecord::Base.logger.level = 4
=> 4
irb(main):003:0> values = ["next year", "american", "october 1"]
=> ["next year", "american", "october 1"]
irb(main):004:0> rule_values = RuleValue.where(value: values)
=> [#<RuleValue id: 7229, value: "next year", is_primary: true, rule_id: 2293, created_at: "2013-09-05 15:11:13", updated_at: "2013-09-05 15:11:13">, #<RuleValue id: 7232, value: "american", is_primary: true, rule_id: 2295, created_at: "2013-09-05 15:16:06", updated_at: "2013-09-05 15:16:06">, #<RuleValue id: 7235, value: "october 1", is_primary: true, rule_id: 2297, created_at: "2013-09-05 15:19:51", updated_at: "2013-09-05 15:19:51">]
irb(main):005:0> rule_values.count
=> 3
irb(main):006:0> rules = Rule.where(id: rule_values.map(&:rule_id), demo_id: 32)
=> [#<Rule id: 2293, points: 3, created_at: "2013-09-05 15:11:13", updated_at: "2013-09-05 19:03:06", reply: "3pts! If you have Fujifilm health care coverage for...", type: nil, description: "Checked-in at the 'Health Care Reform is here!' til...", alltime_limit: 1, referral_points: nil, suggestible: false, demo_id: 32, goal_id: nil, primary_tag_id: nil>, #<Rule id: 2295, points: 3, created_at: "2013-09-05 15:16:06", updated_at: "2013-09-05 19:01:43", reply: "3pts! Great! In accordance with the individual mand...", type: nil, description: "Checked-in at the 'Most American citizens must...\" ...", alltime_limit: 1, referral_points: nil, suggestible: false, demo_id: 32, goal_id: nil, primary_tag_id: nil>, #<Rule id: 2297, points: 3, created_at: "2013-09-05 15:19:51", updated_at: "2013-09-09 00:36:33", reply: "3pts! 2014 enrollment for the health insurance mark...", type: nil, description: "Checked-in at the 'Fall is just around the corner.'...", alltime_limit: 1, referral_points: nil, suggestible: false, demo_id: 32, goal_id: nil, primary_tag_id: nil>]
irb(main):007:0> # The "demo_id: 32" is to make sure that we get Fuji's "october 1" rule value, instead of, say, Covidien's or etc.
irb(main):008:0* rules.count
=> 3
irb(main):009:0> qualifying_acts = Act.where(rule_id: rules.map(&:id)); nil
=> nil
irb(main):010:0> qualifying_acts.count
=> 3113
irb(main):011:0> # Adding the ";nil" suppresses output there, since we don't really care about seeing 3,113 acts
irb(main):012:0* grouped_acts = qualifying_acts.group_by(&:user_id); nil
=> nil
irb(main):013:0> grouped_acts.length
=> 1047
irb(main):014:0> # We want to see somewhat over the length of qualifying_acts / 3, so 1047 sounds reasonable
irb(main):015:0* user_ids_to_tag = grouped_acts.select{|k,v| v.length == 3}.map(&:first); nil
=> nil
irb(main):016:0> # The select picks the users who actually did all 3; map &:first throws away the lists of acts and just leaves us with the user IDs.
irb(main):017:0* user_ids_to_tag[0,10]
=> [21982, 21296, 87677, 86369, 86233, 86475, 21718, 87160, 86673, 89045]
irb(main):018:0> user_ids_to_tag.length
=> 1024
irb(main):019:0> user_ids_to_tag.each do |user_id|
irb(main):020:1* user = User.find(user_id)
irb(main):021:1> user.characteristics ||= {}
irb(main):022:1> user.characteristics[110] = 'Yes'
irb(main):023:1> user.save!
irb(main):024:1> user.schedule_segmentation_update(true)
irb(main):025:1> end; nil

RESET A USER'S PASSWORD
irb(main):037:0> user.forgot_password!
=> true
irb(main):038:0> user.reload
=> #<User id: 10888, name: "Phil Darnowsky", email: "phil@hengage.com", invited: true, demo_id: 134, created_at: "2012-02-06 05:05:45", updated_at: "2013-10-02 19:35:23", invitation_code: "j34j2kl3j52kl3j4kl23j4kl234jkl324j", phone_number: "+14152613077", points: 0, encrypted_password: "fc7bccadbc07ec35c1d14596da8dea62d0226085", salt: "65e3c57b61fd8691cf3987aa4d060a27b4719eae", remember_token: "1e4696e298e20a2ff0b72bab90b4351c0431de23", slug: "phildarnowsky", claim_code: "zzzzlllll", confirmation_token: "f84315faa03ca4ad7003ab474789e0837b790918", won_at: nil, sms_slug: "phildarnowsky", last_suggested_items: "", avatar_file_name: "02222011049.jpg", avatar_content_type: "image/jpeg", avatar_file_size: 941655, avatar_updated_at: "2013-06-06 03:40:29", ranking_query_offset: nil, accepted_invitation_at: "2013-09-03 22:52:41", game_referrer_id: 90745, is_site_admin: true, notification_method: "sms", location_id: 246, new_phone_number: "", new_phone_validation: "", date_of_birth: nil, gender: "male", invitation_method: "client_admin", session_count: 122, privacy_level: "everybody", last_muted_at: nil, last_told_about_mute: nil, mt_texts_today: 0, suppress_mute_notice: nil, follow_up_message_sent_at: "2012-07-09 18:06:43", flashes_for_next_request: nil, characteristics: {2=>true, 17=>true, 20=>true, 19=>false, 21=>false, 22=>true, 51=>"C", 55=>false}, overflow_email: "phil2@hengage.com", tickets: 6, zip_code: "", ssn_hash: nil, is_employee: false, employee_id: "", spouse_id: nil, last_acted_at: "2013-09-26 20:37:55", is_client_admin: nil, ticket_threshold_base: 61, sample_tile_completed: true, get_started_lightbox_displayed: true>
irb(main):039:0> # calling forgot_password! caused confirmation_token to be set
irb(main):040:0* # corresponding password is then https://www.hengage.com/users/phildarnowsky/password/edit?token=f84315faa03ca4ad7003ab474789e0837b790918
irb(main):041:0*

SET “EMAIL MASKING” FOR A DEMO
Set the demo's custom_reply_email_name

SET CUSTOM EMAIL FOR A DEMO
* See data in custom_invitation_emails table for examples.

irb(main):034:0> emails = %w(phil@hengage.com)
=> ["phil@hengage.com"]
irb(main):035:0> emails.each {|email| user = User.find_by_email(email); user.peer_invitations_as_invitee.each(&:destroy); user.invite; user.invite(User.find_by_name('Larry Hannay'))}
=> ["phil@hengage.com"]
irb(main):036:0> CustomInvitationEmail
=> CustomInvitationEmail(id: integer, custom_html_text: text, custom_plain_text: text, custom_subject: text, custom_subject_with_referrer: text, demo_id: integer, created_at: datetime, updated_at: datetime)
irb(main):037:0> cim = CustomInvitationEmail.new(demo_id: 134)
=> #<CustomInvitationEmail id: nil, custom_html_text: nil, custom_plain_text: nil, custom_subject: nil, custom_subject_with_referrer: nil, demo_id: 134, created_at: nil, updated_at: nil>
irb(main):038:0> cim.custom_subject = "Play NPS Wellness and make the most of your HR benefits and programs"
=> "Play NPS Wellness and make the most of your HR benefits and programs"
irb(main):039:0> cim.custom_subject_with_referrer = "[referrer_name] invited you to join NPS Wellness!"
=> "[referrer_name] invited you to join NPS Wellness!"
irb(main):040:0> cim.save
=> true
irb(main):041:0> emails.each {|email| user = User.find_by_email(email); user.peer_invitations_as_invitee.each(&:destroy); user.invite; user.invite(User.find_by_name('Larry Hannay'))}
=> ["phil@hengage.com"]
irb(main):042:0> cim.custom_subject_with_referrer = "[referrer] invited you to join NPS Wellness!"
=> "[referrer] invited you to join NPS Wellness!"
irb(main):043:0> cim.save
=> true
irb(main):044:0> emails.each {|email| user = User.find_by_email(email); user.peer_invitations_as_invitee.each(&:destroy); user.invite; user.invite(User.find_by_name('Larry Hannay'))}
=> ["phil@hengage.com"]
irb(main):045:0> CustomInvitationEmail.count
=> 10
irb(main):046:0> cim.custom_plain_text = %{[no_referrer_block]Welcome to NPS Wellness![/no_referrer_block][referrer_block][referrer] joined NPS Wellness and thinks you should too![/referrer_block]
irb(main):047:0"
irb(main):048:0" An easy and fun way to learn about Wellness programs, benefits and events for NPS Wellness.
irb(main):049:0"
irb(main):050:0" What does NPS Wellness do?
irb(main):051:0"
irb(main):052:0" - Makes workplace communications feel fun and interesting.
irb(main):053:0" - Provides short and timely content that's relevant for you.
irb(main):054:0" - Reduces the volume of dense emails so you don't miss important information.
irb(main):055:0"
irb(main):056:0" How it works:
irb(main):057:0"
irb(main):058:0" - Start. Copy and paste the following link into your browser: [invitation_url].
irb(main):059:0" - Answer questions for points. Each Wednesday you'll receive an email notifying you of new content.
irb(main):060:0" - Win prizes. For every 20 points you earn, you'll get a ticket into the raffle for a prize. You can track the points and tickets you earn in the progress bar at the top of the NPS Wellness homepage.
irb(main):061:0"
irb(main):062:0" Questions? Send us an email to support@hengage.com.
irb(main):063:0"
irb(main):064:0"
irb(main):065:0" }
=> "[no_referrer_block]Welcome to NPS Wellness![/no_referrer_block][referrer_block][referrer] joined NPS Wellness and thinks you should too![/referrer_block]\n\nAn easy and fun way to learn about Wellness programs, benefits and events for NPS Wellness.\n\nWhat does NPS Wellness do?\n\n- Makes workplace communications feel fun and interesting.\n- Provides short and timely content that's relevant for you.\n- Reduces the volume of dense emails so you don't miss important information.\n\nHow it works:\n\n- Start. Copy and paste the following link into your browser: [invitation_url].\n- Answer questions for points. Each Wednesday you'll receive an email notifying you of new content.\n- Win prizes. For every 20 points you earn, you'll get a ticket into the raffle for a prize. You can track the points and tickets you earn in the progress bar at the top of the NPS Wellness homepage.\n\nQuestions? Send us an email to support@hengage.com.\n\n\n"
irb(main):066:0> cim.custom_html_text = %{<center>
irb(main):067:0" <table width="550" border="0" cellspacing="0" cellpadding="0">
irb(main):068:0" <tbody>
irb(main):069:0" <tr>
irb(main):070:0" <td><center>
irb(main):071:0" <table border="0" cellspacing="0" cellpadding="0">
irb(main):072:0" <tbody>
irb(main):073:0" <tr style="font-family: 'helvetica neue', helvetica, sans-serif; font-size: 7px; line-height: .9em;">
irb(main):074:0" <td style="font-family: arial, sans-serif; margin: 0px; background-color: #4da968; font-size: 5px;" width="138">&nbsp;</td>
irb(main):075:0" <td style="font-family: arial, sans-serif; margin: 0px; background-color: #50698c; font-size: 5px;" width="138">&nbsp;</td>
irb(main):076:0" <td style="font-family: arial, sans-serif; margin: 0px; background-color: #ff7d00; font-size: 5px;" width="274">&nbsp;</td>
irb(main):077:0" </tr>
irb(main):078:0" </tbody>
irb(main):079:0" </table>
irb(main):080:0" </center></td>
irb(main):081:0" </tr>
irb(main):082:0" <tr>
irb(main):083:0" <td height="10">&nbsp;</td>
irb(main):084:0" </tr>
irb(main):085:0" <tr style="font-family: 'helvetica neue', helvetica, sans-serif;">
irb(main):086:0" <td style="text-align: left;">
irb(main):087:0" <h1 style="color: #292929; font-weight: 300;">[no_referrer_block]Welcome to NPS Wellness![/no_referrer_block][referrer_block][referrer] joined NPS Wellness and thinks you should too![/referrer_block]</h1>
irb(main):088:0" <h2 style="color: #a8a8a8; font-weight: 500;">An easy and fun way to learn about Wellness programs, benefits and events for NPS Wellness.</h2>
irb(main):089:0" </td>
irb(main):090:0" </tr>
irb(main):091:0" <tr>
irb(main):092:0" <td height="10">&nbsp;</td>
irb(main):093:0" </tr>
irb(main):094:0" <tr>
irb(main):095:0" <td><center>
irb(main):096:0" <table border="0" cellspacing="0" cellpadding="0">
irb(main):097:0" <tbody>
irb(main):098:0" <tr style="background: #4DA968;">
irb(main):099:0" <td style="line-height: .65em;" colspan="3" height="0">&nbsp;</td>
irb(main):100:0" </tr>
irb(main):101:0" <tr style="background: #4DA968;">
irb(main):102:0" <td width="30">&nbsp;</td>
irb(main):103:0" <td><a style="color: #ffffff; display: block; font-family: 'helvetica neue', helvetica, sans-serif; font-size: 20px; font-weight: bold; text-decoration: none; padding: .5em 2em;" href="[invitation_url]" target="_blank">Get started</a></td>
irb(main):104:0" <td width="30">&nbsp;</td>
irb(main):105:0" </tr>
irb(main):106:0" <tr style="background: #4DA968;">
irb(main):107:0" <td style="border-bottom: 5px #428E50 solid; line-height: .65em;" colspan="3" height="0">&nbsp;</td>
irb(main):108:0" </tr>
irb(main):109:0" </tbody>
irb(main):110:0" </table>
irb(main):111:0" </center></td>
irb(main):112:0" </tr>
irb(main):113:0" <tr>
irb(main):114:0" <td height="50">&nbsp;</td>
irb(main):115:0" </tr>
irb(main):116:0" <tr style="font-family: 'helvetica neue', helvetica, sans-serif;">
irb(main):117:0" <td style="text-align: left;">
irb(main):118:0" <h2 style="color: #50698c; font-weight: 500;">What does NPS Wellness do?</h2>
irb(main):119:0" <ul style="list-style-type: disc;">
irb(main):120:0" <li style="padding-bottom: 0.7em;">Makes workplace communications feel fun and interesting.</li>
irb(main):121:0" <li style="padding-bottom: 0.7em;">Provides short and timely content that's relevant for you.</li>
irb(main):122:0" <li style="padding-bottom: 0.7em;">Reduces the volume of dense emails so you don't miss important information.</li>
irb(main):123:0" </ul>
irb(main):124:0" </td>
irb(main):125:0" </tr>
irb(main):126:0" <tr>
irb(main):127:0" <td height="10">&nbsp;</td>
irb(main):128:0" </tr>
irb(main):129:0" <tr style="font-family: 'helvetica neue', helvetica, sans-serif;">
irb(main):130:0" <td style="text-align: left;">
irb(main):131:0" <h2 style="color: #50698c; font-weight: 500;">How it works:</h2>
irb(main):132:0" <ul style="list-style-type: disc;">
irb(main):133:0" <li style="padding-bottom: 0.7em;"><strong>Start.</strong> Click the green "Get started" button.</li>
irb(main):134:0" <li style="padding-bottom: 0.7em;"><strong>Answer questions for points. </strong>Each Wednesday you'll receive an email notifying you of new content.</li>
irb(main):135:0" <li style="padding-bottom: 0.7em;"><strong>Win prizes. </strong>For every 20 points you earn, you'll get a ticket into the raffle for a prize. You can track the points and tickets you earn in the progress bar at the top of the NPS Wellness homepage.</li>
irb(main):136:0" </ul>
irb(main):137:0" <p style="text-align: center;">Questions? Send us an&nbsp;<a href="mailto:support@hengage.com">Email</a>.&nbsp;</p>
irb(main):138:0" <p style="text-align: center;">&nbsp;</p>
irb(main):139:0" </td>
irb(main):140:0" </tr>
irb(main):141:0" </tbody>
irb(main):142:0" </table>
irb(main):143:0" </center>}
=> "<center>\n<table width=\"550\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\n<tbody>\n<tr>\n<td><center>\n<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\n<tbody>\n<tr style=\"font-family: 'helvetica neue', helvetica, sans-serif; font-size: 7px; line-height: .9em;\">\n<td style=\"font-family: arial, sans-serif; margin: 0px; background-color: #4da968; font-size: 5px;\" width=\"138\">&nbsp;</td>\n<td style=\"font-family: arial, sans-serif; margin: 0px; background-color: #50698c; font-size: 5px;\" width=\"138\">&nbsp;</td>\n<td style=\"font-family: arial, sans-serif; margin: 0px; background-color: #ff7d00; font-size: 5px;\" width=\"274\">&nbsp;</td>\n</tr>\n</tbody>\n</table>\n</center></td>\n</tr>\n<tr>\n<td height=\"10\">&nbsp;</td>\n</tr>\n<tr style=\"font-family: 'helvetica neue', helvetica, sans-serif;\">\n<td style=\"text-align: left;\">\n<h1 style=\"color: #292929; font-weight: 300;\">[no_referrer_block]Welcome to NPS Wellness![/no_referrer_block][referrer_block][referrer] joined NPS Wellness and thinks you should too![/referrer_block]</h1>\n<h2 style=\"color: #a8a8a8; font-weight: 500;\">An easy and fun way to learn about Wellness programs, benefits and events for NPS Wellness.</h2>\n</td>\n</tr>\n<tr>\n<td height=\"10\">&nbsp;</td>\n</tr>\n<tr>\n<td><center>\n<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\n<tbody>\n<tr style=\"background: #4DA968;\">\n<td style=\"line-height: .65em;\" colspan=\"3\" height=\"0\">&nbsp;</td>\n</tr>\n<tr style=\"background: #4DA968;\">\n<td width=\"30\">&nbsp;</td>\n<td><a style=\"color: #ffffff; display: block; font-family: 'helvetica neue', helvetica, sans-serif; font-size: 20px; font-weight: bold; text-decoration: none; padding: .5em 2em;\" href=\"[invitation_url]\" target=\"_blank\">Get started</a></td>\n<td width=\"30\">&nbsp;</td>\n</tr>\n<tr style=\"background: #4DA968;\">\n<td style=\"border-bottom: 5px #428E50 solid; line-height: .65em;\" colspan=\"3\" height=\"0\">&nbsp;</td>\n</tr>\n</tbody>\n</table>\n</center></td>\n</tr>\n<tr>\n<td height=\"50\">&nbsp;</td>\n</tr>\n<tr style=\"font-family: 'helvetica neue', helvetica, sans-serif;\">\n<td style=\"text-align: left;\">\n<h2 style=\"color: #50698c; font-weight: 500;\">What does NPS Wellness do?</h2>\n<ul style=\"list-style-type: disc;\">\n<li style=\"padding-bottom: 0.7em;\">Makes workplace communications feel fun and interesting.</li>\n<li style=\"padding-bottom: 0.7em;\">Provides short and timely content that's relevant for you.</li>\n<li style=\"padding-bottom: 0.7em;\">Reduces the volume of dense emails so you don't miss important information.</li>\n</ul>\n</td>\n</tr>\n<tr>\n<td height=\"10\">&nbsp;</td>\n</tr>\n<tr style=\"font-family: 'helvetica neue', helvetica, sans-serif;\">\n<td style=\"text-align: left;\">\n<h2 style=\"color: #50698c; font-weight: 500;\">How it works:</h2>\n<ul style=\"list-style-type: disc;\">\n<li style=\"padding-bottom: 0.7em;\"><strong>Start.</strong> Click the green \"Get started\" button.</li>\n<li style=\"padding-bottom: 0.7em;\"><strong>Answer questions for points. </strong>Each Wednesday you'll receive an email notifying you of new content.</li>\n<li style=\"padding-bottom: 0.7em;\"><strong>Win prizes. </strong>For every 20 points you earn, you'll get a ticket into the raffle for a prize. You can track the points and tickets you earn in the progress bar at the top of the NPS Wellness homepage.</li>\n</ul>\n<p style=\"text-align: center;\">Questions? Send us an&nbsp;<a href=\"mailto:support@hengage.com\">Email</a>.&nbsp;</p>\n<p style=\"text-align: center;\">&nbsp;</p>\n</td>\n</tr>\n</tbody>\n</table>\n</center>"
irb(main):144:0> cim.save
=> true
irb(main):145:0> emails = %w(phil@hengage.com kate@hengage.com)
=> ["phil@hengage.com", "kate@hengage.com"]
irb(main):146:0> emails.each {|email| user = User.find_by_email(email); user.peer_invitations_as_invitee.each(&:destroy); user.invite; user.invite(User.find_by_name('Larry Hannay'))}
=> ["phil@hengage.com", "kate@hengage.com"]

THE DREADED BULK LOADER
Some notes on the actual session below...
If you start with an XLS file => need to convert to CSV =>
* No spaces in filename
* Delete the first row (which names the fields)
First load the CSV file to Amazon S3. 
Instructions for accessing S3 are above.
Bulk-load files are stored in the hengage-tmp bucket.

Perform locally to make sure can process entire file without errors before creating/updating users in production database:
* Make sure redis-server and delayed-job worker are running.
* Create a demo to hold the users (all of which will be created because none already exist to be updated). 
** The one created below has an id of 41
** REMEMBER TO SUBSTITUTE THE DEMO_ID OF THE DEMO IN PRODUCTION WHEN YOU DO THIS FOR REAL!

Basically you run a rake task which consists of a chopper and a feeder...
chopper: Parses the binary blob of data in the S3 bucket for processing by a redis server, which is redis-server locally and at redistogo.com when you do this for real.
It will produce one redis record: the key is the filename and the value is a queue of all of the csv records => could be a pretty big queue.
It then creates a feeder, which is a delayed job which grabs each entry from the queue and creates a delayed job for it which, when run, will either create or update the user in the csv record.
This means that the number of resque queue elements should be decreasing while the number of delayed jobs are increasing.
* Given that there are typically 5 workers running in production, when you do this for real they should be able to handle the jobs as soon as they are created.
* You can monitor the number of delayed jobs by opening up a Rails console and entering “Delayed::Job.count” repeatedly.
* To monitor the number of elements in the queue you need to create a redis client from which to issue commands to the redis server.
Fire up a Rails console (because we use a Ruby library to make things easier):
redis = Redis.new URL
redis.llen <key>
* You do not need to specify the URL when running locally.
* For “real”, you get the URL from heroku configuration (which appears in the console-session output below).
* The <key> is filename (you want the length of its value, which is the queue of csv elements)
* Other redis commands can be found at: http://redis.io/commands (the 'llen' command is under 'Lists')

larry@hengage:~$ heroku config -a hengage
=== hengage Config Vars
ADMINIUM_URL: https://adminium.herokuapp.com/heroku/accounts/7518098a8
AVATAR_BUCKET: hengage-avatars-production
AWS_ACCESS_KEY_ID: AKIAJVBKNOIHHPUOUHYA
AWS_SECRET_ACCESS_KEY: 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
BUNDLE_WITHOUT: development:test:cucumber
CONSOLE_AUTH: app392684:AKpcypXyLrCI7DsUwsAe
:	:	:	:	:	:	:	:	:	:
REDISTOGO_URL:               redis://redistogo:6718b47d991f95efc8dbe8a6779c345b@barreleye.redistogo.com:10314/
:	:	:	:	:	:	:	:	:	:
< ... Many More – Just need the AWS_xxx and REDISTOGO_URL ones...>

larry@hengage:~/RubyMine/Hengage$ 
# Notice setting environment variables before specifying command 
# There are no quotes around the -s tag data 
# 'email' is the “uniqueness” field in the CSV data for each employee; usually either this or 'employee_id'
# Filename would typically contain underscores instead of camel-case, i.e. aegis_eligiblity_file.csv (I just entered it wrong for this example)
AWS_ACCESS_KEY_ID=AKIAJVBKNOIHHPUOUHYA AWS_SECRET_ACCESS_KEY=wVWjV8UxSl4y22x3SmSNsmUvRrRSGCIdXOEr9rM6 rake bulk_load[hengage-tmp,AegisEligiblityFile.csv,41,email] -- -s name,email

SCHEMA IS "name,email"
Preparing to chop the file at hengage-tmp/AegisEligiblityFile.csv into Redis.
Chopping finished! 62 lines loaded into Redis.
Scheduling load into demo 41. This may take some time.
Job ID for feeder is 29425
(NOTE: THIS ERROR ALWAYS SHOWS UP AND CAN BE IGNORED)
rake aborted!
Don't know how to build task 'name,email'
(See full trace by running task with --trace)
larry@hengage:~/RubyMine/Hengage$ 

DONE RUNNING LOCALLY => ASK ONE OF THE K'S TO CONFIRM 3-5 DATA ELEMENTS (I.E. USERS) AS SOME KIND OF SANITY CHECK THAT THE THING WORKED PROPERLY. SEAL OF APPROVAL FROM THE K'S =>
NOW RUN IN PRODUCTION - NOTICE HOW demo_id IS DIFFERENT! (41 vs. 119)
Basically it is the same rake command except it has quotes around it, starts with “heroku run” and ends with “-a hengage”

larry@hengage:~/RubyMine/Hengage$ heroku run "rake bulk_load[hengage-tmp,AegisEligiblityFile.csv,119,email] -- -s name,email" -a hengage
Running `rake bulk_load[hengage-tmp,AegisEligiblityFile.csv,119,email] -- -s name,email` attached to terminal... up, run.8335
<Some deprecation warnings regarding plugins that can be ignored>
SCHEMA IS "name,email"
Preparing to chop the file at hengage-tmp/AegisEligiblityFile.csv into Redis.
Chopping finished! 62 lines loaded into Redis.
Scheduling load into demo 119. This may take some time.
Job ID for feeder is 5889622
(REMEMBER: THIS ERROR ALWAYS SHOWS UP AND CAN BE IGNORED)
rake aborted!
Don't know how to build task 'name,email'

(See full trace by running task with --trace)
larry@hengage:~/RubyMine/Hengage$ 


