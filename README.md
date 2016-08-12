HEngage
========

Information about the HEngage Rails app

Laptop setup
------------

### Mac
[Thoughtbot Laptop](https://github.com/thoughtbot/laptop) is a script to set up a Mac OS X laptop for Rails development.

Or just install [homebrew](http://brew.sh) then do brew install postgres, redis, mongodb, Qt, ImageMagick  

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

Getting Postgres authentication can be a bit tricky, especially if you've never done it before. There is a simple authentication config file available at https://github.com/vladig17/hengage/wiki/Development-pg_hba.conf. However, YOU MUST NEVER USE THIS CONFIGURATION IN PRODUCTION BECAUSE IT IS TOTALLY INSECURE. IT IS FOR DEVELOPMENT ONLY.

To get started. copy the configuration from the address above to `/etc/postgresql/9.1/main/` (version number might be different) and restart Postgres.

Then you'll need to create a database user (Postgres keeps its own lists of users separate from the system's) to use:

    $ sudo su postgres
    $ createuser joe # this should be the same as your system username

It will ask if the new user should be a superuser: say yes. Again, this is fine for a development machine but not a production server.

####  Use  [RBENV](https://github.com/rbenv/rbenv) if you have need to support multiple ruby versions *

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
    

Setting up the app itself
-------------------------

Get the HEngage source code:

    git clone git@github.com:vladig17/hengage.git

Install the dependent Ruby libraries:

    bundle

Create your development and test databases. (Note: Two distinct steps: 1 for development and 1 for test):

    rake db:create

Load the development database:
    rake db:schema:load

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
    
CONFIG vars
-----------
Make sure to set these vars as appropriate.  Below is for example purpose only

MAX_SELECTORS_DEFAULT                             3072 

(IE9 craps out after this number of css selectors
Acutally the limit is 4095 but there maybe a file size limitation as well so we
set the number to 3072 which should also keep us under the file size limit. Yes
it's a hack but it's IE9)

ACTIVITY_SESSION_THRESHOLD:                       120
APP_HOST:                                         hengage-dev.herokuapp.com
AVATAR_BUCKET:                                    hengage-avatars-development
AWS_ACCESS_KEY_ID:                                [KEY]
AWS_BULK_UPLOAD_ACCESS_KEY_ID:                    [KEY] 
AWS_BULK_UPLOAD_SECRET_ACCESS_KEY:                [SECRET]
AWS_SECRET_ACCESS_KEY:                            [KEY]
BILLING_INFORMATION_ENTERED_NOTIFICATION_ADDRESS: team@air.bo
DATABASE_URL:                                     [URL]
EMAIL_HOST:                                       hengage-dev.herokuapp.com
EMAIL_PROTOCOL:                                   https
FOG_DIRECTORY:                                    hengage-tiles-development
FOG_PROVIDER:                                     AWS
HEROKU_APP_NAME:                                  hengage-dev
LOG_LEVEL:                                        INFO
MAX_SELECTORS_DEFAULT:                            3072
MIXPANEL_API_KEY:                                 [KEY_ID]
MIXPANEL_API_SECRET:                              [SECRET]
MIXPANEL_TOKEN:                                   [TOKEN]
MONGOHQ_URL:                                      [URL]
MONGOLAB_URI:                                     [URL]
NEW_RELIC_APP_NAME:                               hengage-dev
NEW_RELIC_LICENSE_KEY:                            [KEY]
NEW_RELIC_LOG:                                    stdout
PROFILABLE_USERS:                                 herby@airbo.com,a.v.brychak@gmail.com,kate-admin@airbo.com
RACK_ENV:                                         development
RAILS_ENV:                                        production
REDISTOGO_URL:                                    [URL]
S3_TILE_BUCKET:                                   hengage-tiles-development
SENDGRID_PASSWORD:                                [PWD]
SENDGRID_USERNAME:                                [USER]
STRIPE_API_PRIVATE_KEY:                           [KEY]
STRIPE_API_PUBLIC_KEY:                            [KEY]
TILE_BUCKET:                                      hengage-tiles-development




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
Get the logo from the K's. If it's a .psd file => have them convert it to a .png or .jpg
Create bucket for logo image, e.g. heinekin_logo
Clck 'Upload' and add a file. 
Then, button at bottom:
Set details > set permissions > make everything public
Upload image file to bucket
Need to click on the uploaded image filename (to get it listed by itself) then right-click > Properties > Link
Now create a Skin object for the demo and set its logo_url to the 'Link':
Skin.create! demo_id: 185, logo_url: 'https://s3.amazonaws.com/bedford_board_logo/fujifilm.png'

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
* The email text is the final result of setting up an email. Does not reflect an actual user session because the original one had errors (went over it quickly) and during my first real one all hell broke loose. So... whatever.
irb(main):037:0> cim = CustomInvitationEmail.new(demo_id: 185)
=> #<CustomInvitationEmail id: nil, custom_html_text: nil, custom_plain_text: nil, custom_subject: nil, custom_subject_with_referrer: nil, demo_id: 185, created_at: nil, updated_at: nil>
irb(main):038:0> cim.custom_subject = "Check out the Bedford Board!"
=> "Check out the Bedford Board!"
irb(main):039:0> cim.custom_subject_with_referrer = "[referrer] invited you to check out the Bedford Board!"
=> "[referrer] invited you to check out the Bedford Board!"
irb(main):040:0> cim.save
=> true
irb(main):046:0> cim.custom_plain_text = %(
[no_referrer_block]You're invited to check out the Bedford Board - an easy and fun way to learn about what's going on in Bedford and at Fujifilm.[/no_referrer_block][referrer_block][referrer] invited you to check out the Bedford Board - an easy and fun way to learn about what's going on in Bedford and at Fujifilm.[/referrer_block]\n\nOn the Bedford Board, you'll find the normal HealthFocus tiles, as well as new tiles about events and updates that are just for Bedford employees.\n\nThese tiles will be posted throughout the year, and you'll receive an email when new ones are available.\n\nHow it works:\n\n* Go to [invitation_url] to get started. Have a smartphone? Now you can access the website on your phone too!\n* Just like in rounds of HealthFocus, answer questions for points. You'll receive an email notifying you when new tiles are posted. Make sure to watch your email since tiles won't be hung up around the office anymore.\n* Win prizes. For every 20 points you earn, you'll get a ticket into the raffle for a prize. Watch for tiles announcing new prize drawings throughout the year.\n\nQuestions? Send an email to support@hengage.com\n\n
irb(main):066:0> )
irb(main):066:0> cim.custom_html_text = %(
<div style=\"color: #222222; font-family: arial, sans-serif; font-size: 13px;\">\n<div>[no_referrer_block]You're invited to check out the Bedford Board - an easy and fun way to learn about what's going on in Bedford and at Fujifilm.[/no_referrer_block][referrer_block][referrer] invited you to check out the Bedford Board - an easy and fun way to learn about what's going on in Bedford and at Fujifilm.[/referrer_block]&nbsp;</div>\n<div>&nbsp;</div>\n<div>On the Bedford Board, you'll find the normal HealthFocus tiles, as well as new tiles about events and updates that are just for Bedford employees. These tiles will be posted throughout the year, and you'll receive an email when new ones are available.</div>\n<div>&nbsp;</div>\n<div>Click&nbsp;<a href=\"[invitation_url]\">here</a> to get started.</div>\n<div>&nbsp;</div>\n<div><strong>How it works:</strong></div>\n<div>\n<ul>\n<li>Click the link to get started. Have a smartphone? Now you can access the website on your phone too!</li>\n<li>Just like in rounds of HealthFocus, answer questions for points. You'll receive an email notifying you when new tiles are posted. Make sure to watch your email since tiles won't be hung up around the office anymore.</li>\n<li>Win prizes. For every 20 points you earn, you'll get a ticket into the raffle for a prize. Watch for tiles announcing new prize drawings throughout the year.&nbsp;</li>\n</ul>\n</div>\n<div>Questions? Send us an email at&nbsp;<a style=\"color: #1155cc;\" href=\"mailto:support@hengage.com\" target=\"_blank\">support@hengage.com</a>.</div>\n</div><br /><br />
irb(main):143:0" )
irb(main):144:0> cim.save

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

================================

To create rules and acts for a user's activity feed:

Create a Rule in "site_admin" for the demo. 
* One of the Ks typically does this. 
* Since we are creating acts for the users activity feeds we want a valid description but a rule value that users won't discover by accident. Here is a good example from the Heineken demo d. r is the Rule and rv its RuleValue:

irb(main):108:0> d
=> #<Demo id: 135, name: "Heineken HEngage", created_at: "2013-09-04 21:35:47", updated_at: "2013-10-02 17:25:33", seed_points: nil, custom_welcome_message: "Welcome to Heineken HEngage! Watch for an email to...", ends_at: nil, followup_welcome_message: "", followup_welcome_message_delay: 0, credit_game_referrer_threshold: 100000, game_referrer_bonus: 5, use_standard_playbook: false, begins_at: nil, phone_number: "+19146195717", prize: "", help_message: "", email: "heineken@playhengage.com", unrecognized_user_message: "", act_too_early_message: "", act_too_late_message: "", referred_credit_bonus: 2, survey_answer_activity_message: "", login_announcement: "", total_user_rankings_last_updated_at: nil, average_user_rankings_last_updated_at: nil, mute_notice_threshold: nil, join_type: "pre-populated", sponsor: nil, example_tooltip: "", example_tutorial: "", ticket_threshold: 20, client_name: "Heineken", custom_reply_email_name: "The People Department", custom_already_claimed_message: "", use_post_act_summaries: true, custom_support_reply: "", internal_domains: [], show_invite_modal_when_game_closed: false, tile_digest_email_sent_at: "2013-10-02 17:25:33", website_locked: false, tutorial_type: "multiple_choice", unclaimed_users_also_get_digest: true>

Now create an act for each user. Note that you have to set the text to something (typically the rule's description) because if you don't the created act will have its "hidden" attribute set to "true" => won't show up in the feed.

irb(main):115:0* Act.create! demo: d, rule: r, text: r.description, user: u
   (1.3ms)  BEGIN
  SQL (2.0ms)  INSERT INTO "acts" ("created_at", "creation_channel", "demo_id", "hidden", "inherent_points", "privacy_level", "referring_user_id", "rule_id", "rule_value_id", "text", "updated_at", "user_id") VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) RETURNING "id"  [["created_at", Mon, 28 Oct 2013 12:59:42 EDT -04:00], ["creation_channel", ""], ["demo_id", 135], ["hidden", false], ["inherent_points", nil], ["privacy_level", "connected"], ["referring_user_id", nil], ["rule_id", 2356], ["rule_value_id", nil], ["text", "Completed Alex, emailed my Personal Benefits Webpage to thepeopledepartment@heinekenusa.com and earned 5 extra tickets towards the prize drawing!"], ["updated_at", Mon, 28 Oct 2013 12:59:42 EDT -04:00], ["user_id", 122719]]
  User Exists (1.4ms)  SELECT 1 AS one FROM "users" WHERE ("users"."email" = 'jfrancisco@heinekenusa.com' AND "users"."id" != 122719) LIMIT 1
   (1.6ms)  SELECT COUNT(count_column) FROM (SELECT 1 AS count_column FROM "users" WHERE (phone_number = '+13475247226' AND id != 122719) LIMIT 1) subquery_for_count 
  Demo Load (1.6ms)  SELECT "demos".* FROM "demos" WHERE "demos"."id" = 135 LIMIT 1
  RuleValue Load (1.6ms)  SELECT "rule_values".* FROM "rule_values" INNER JOIN "rules" ON "rule_values"."rule_id" = "rules"."id" WHERE "rules"."demo_id" = 135
  User Exists (1.4ms)  SELECT 1 AS one FROM "users" WHERE ("users"."slug" = 'yudelkaking' AND "users"."id" != 122719) LIMIT 1
  User Exists (1.3ms)  SELECT 1 AS one FROM "users" WHERE ("users"."sms_slug" = 'yudelkaking' AND "users"."id" != 122719) LIMIT 1
  User Exists (2.5ms)  SELECT 1 AS one FROM "users" WHERE ("users"."invitation_code" = 'b74d1322a9201595282affa6157eabe763c13503' AND "users"."id" != 122719) LIMIT 1
  User Load (1.6ms)  SELECT "users".* FROM "users" WHERE "users"."overflow_email" = 'jfrancisco@heinekenusa.com'
   (2.0ms)  UPDATE "users" SET "last_acted_at" = '2013-10-28 16:59:42.445244', "updated_at" = '2013-10-28 16:59:42.467708', "flashes_for_next_request" = '--- 
...
', "characteristics" = '--- {}
' WHERE "users"."id" = 122719
  SQL (2.0ms)  INSERT INTO "delayed_jobs" ("attempts", "created_at", "failed_at", "handler", "last_error", "locked_at", "locked_by", "priority", "queue", "run_at", "updated_at") VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) RETURNING "id"  [["attempts", 0], ["created_at", Mon, 28 Oct 2013 12:59:42 EDT -04:00], ["failed_at", nil], ["handler", "--- !ruby/object:Delayed::PerformableMethod\nobject: !ruby/ActiveRecord:User\n  attributes:\n    id: '122719'\n    name: Yudelka King\n    email: jfrancisco@heinekenusa.com\n    invited: f\n    demo_id: '135'\n    created_at: '2013-09-11 17:36:40.977462'\n    updated_at: 2013-10-28 16:59:42.467708636 Z\n    invitation_code: b74d1322a9201595282affa6157eabe763c13503\n    phone_number: '+13475247226'\n    points: '139'\n    encrypted_password: fbc039a1802977af69ae3370c5b19ed83b3f3dcb\n    salt: bc1ace68216eaa4e7f108ca8aea5cbbca8fb2024\n    remember_token: 5a8bdb3e14033088b69cd8d2be88f03862eeca98\n    slug: yudelkaking\n    claim_code: \n    confirmation_token: \n    won_at: \n    sms_slug: yudelkaking\n    last_suggested_items: ''\n    avatar_file_name: \n    avatar_content_type: \n    avatar_file_size: \n    avatar_updated_at: \n    ranking_query_offset: \n    accepted_invitation_at: '2013-10-02 13:40:08.634607'\n    game_referrer_id: \n    is_site_admin: f\n    notification_method: both\n    location_id: \n    new_phone_number: ''\n    new_phone_validation: ''\n    date_of_birth: \n    gender: \n    invitation_method: ''\n    session_count: '2'\n    privacy_level: connected\n    last_muted_at: \n    last_told_about_mute: \n    mt_texts_today: '0'\n    suppress_mute_notice: f\n    follow_up_message_sent_at: \n    flashes_for_next_request: !ruby/struct:ActiveRecord::AttributeMethods::Serialization::Attribute\n      coder: !ruby/object:ActiveRecord::Coders::YAMLColumn\n        object_class: !ruby/class 'Object'\n      value: ! \"--- \\n...\\n\"\n      state: :serialized\n    characteristics: !ruby/struct:ActiveRecord::AttributeMethods::Serialization::Attribute\n      coder: !ruby/object:ActiveRecord::Coders::YAMLColumn\n        object_class: !ruby/class 'Object'\n      value: ! '--- {}\n\n'\n      state: :serialized\n    overflow_email: ''\n    tickets: '6'\n    zip_code: \n    ssn_hash: \n    is_employee: t\n    employee_id: '17001164'\n    spouse_id: \n    last_acted_at: 2013-10-28 12:59:42.445244142 -04:00\n    is_client_admin: f\n    ticket_threshold_base: '0'\n    sample_tile_completed: t\n    get_started_lightbox_displayed: t\nmethod_name: :update_segmentation_info\nargs:\n- false\n"], ["last_error", nil], ["locked_at", nil], ["locked_by", nil], ["priority", 100], ["queue", nil], ["run_at", Mon, 28 Oct 2013 12:59:42 EDT -04:00], ["updated_at", Mon, 28 Oct 2013 12:59:42 EDT -04:00]]
  Goal Load (1.7ms)  SELECT "goals".* FROM "goals" INNER JOIN "rules" ON "goals"."id" = "rules"."goal_id" WHERE "rules"."id" = 2356 LIMIT 1
  TimedBonus Load (1.3ms)  SELECT "timed_bonus".* FROM "timed_bonus" WHERE (fulfilled IS DISTINCT FROM true AND expires_at > '2013-10-28 16:59:42.488958' AND user_id = 122719 AND demo_id = 135)
  TileCompletion Load (1.7ms)  SELECT "tile_completions".* FROM "tile_completions" WHERE "tile_completions"."user_id" = 122719
  Tile Load (1.7ms)  SELECT "tiles".* FROM "tiles" INNER JOIN trigger_rule_triggers ON trigger_rule_triggers.tile_id = tiles.id WHERE "tiles"."demo_id" = 135 AND "tiles"."status" = 'active' AND (trigger_rule_triggers.rule_id = 2356) AND (start_time < '2013-10-28 16:59:42.491086' OR start_time IS NULL) AND (end_time > '2013-10-28 16:59:42.491199' OR end_time IS NULL)
   (1.9ms)  SELECT COUNT(*) FROM "friendships" WHERE "friendships"."state" = 'accepted' AND "friendships"."user_id" = 122719
   (1.2ms)  SELECT COUNT(*) FROM "friendships" WHERE "friendships"."state" = 'accepted' AND "friendships"."friend_id" = 122719
  SQL (1.6ms)  INSERT INTO "delayed_jobs" ("attempts", "created_at", "failed_at", "handler", "last_error", "locked_at", "locked_by", "priority", "queue", "run_at", "updated_at") VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) RETURNING "id"  [["attempts", 0], ["created_at", Mon, 28 Oct 2013 12:59:42 EDT -04:00], ["failed_at", nil], ["handler", "--- !ruby/object:Delayed::PerformableMethod\nobject: !ruby/object:Mixpanel::Tracker\n  token: 0bf0dc3d09bdeb203c0678181a70d99a\n  async: false\n  persist: false\n  env:\n    mixpanel_events: []\n  api_key: \nmethod_name: :track\nargs:\n- acted\n- :time: 2013-10-28 12:59:42.498424066 -04:00\n  :rule_value: $%rz234\n  :primary_tag: \n  :secondary_tags: []\n  :tagged_user_id: \n  :channel: ''\n  :suggestion_code: \n  :distinct_id: 122719\n  :id: 122719\n  :email: jfrancisco@heinekenusa.com\n  :game: Heineken HEngage\n  :following_count: 11\n  :followers_count: 11\n  :score: 139\n  :account_creation_date: 2013-09-11\n  :joined_game_date: 2013-10-02\n  :location: \n"], ["last_error", nil], ["locked_at", nil], ["locked_by", nil], ["priority", 0], ["queue", nil], ["run_at", Mon, 28 Oct 2013 12:59:42 EDT -04:00], ["updated_at", Mon, 28 Oct 2013 12:59:42 EDT -04:00]]
   (8.3ms)  COMMIT
=> #<Act id: 749475, user_id: 122719, text: "Completed Alex, emailed my Personal Benefits Webpag...", created_at: "2013-10-28 16:59:42", updated_at: "2013-10-28 16:59:42", rule_id: 2356, inherent_points: nil, demo_id: 135, referring_user_id: nil, creation_channel: "", hidden: false, privacy_level: "connected", rule_value_id: nil>
irb(main):116:0> 

Finally, you will typically update the tickets and/or points for each user. Nothing special here, just the appropriate method call:
u.update_attributes tickets: u.tickets + 3, points: u.points + 5

=====================================

DUPLICATE A CLAIM-STATE MACHINE
For example, you want the 'SonoSite' demo (variable 'sono') to have the same state rules as the 'HealthFocus' demo (variable 'hf') [The 'start_state_id' defaults to 1]:
irb(main):014:0* ClaimStateMachine.create(states: hf.claim_state_machine.states, demo: sono)
   (1.4ms)  BEGIN
  SQL (86.8ms)  INSERT INTO "claim_state_machines" ("created_at", "demo_id", "start_state_id", "states", "updated_at") VALUES ($1, $2, $3, $4, $5) RETURNING "id"  [["created_at", Tue, 29 Oct 2013 13:54:34 EDT -04:00], ["demo_id", 203], ["start_state_id", 1], ["states", "---\n1: !ruby/struct:ClaimState\n  finder_method: :by_claim_code\n  next_state_on_ambiguity_id: 2\n  ambiguity_message: ! 'Sorry, we need a little more info to create your account.\n    Please send your month & day of birth (format: MMDD).'\n  unrecognized_information_message: I can't find you in my records. Did you claim\n    your account yet? If not, send your first initial and last name (if you are John\n    Smith, send \"jsmith\").\n  valid_format: \n  invalid_format_message: \n  notify_admins_on_failure: \n  already_claimed_message: That ID \"@{claim_information}\" is already taken. If you're\n    trying to register your account, please send in your own ID first by itself.\n2: !ruby/struct:ClaimState\n  finder_method: :by_date_of_birth_string\n  next_state_on_ambiguity_id: 3\n  ambiguity_message: Sorry, we need a little more info to create your account. Please\n    send your employee ID.\n  unrecognized_information_message: Sorry, I don't recognize that date of birth. Please\n    try a different one, or contact support@hengage.com for help.\n  valid_format: !ruby/regexp /^\\d{4}$/\n  invalid_format_message: ! 'Sorry, I didn''t quite get that. Please send your month\n    & date of birth as MMDD (example: September 10 = 0910).'\n  notify_admins_on_failure: \n  already_claimed_message: It looks like that account is already claimed. Please try\n    a different date of birth, or contact support@hengage.com for help.\n3: !ruby/struct:ClaimState\n  finder_method: :by_employee_id\n  next_state_on_ambiguity_id: 3\n  ambiguity_message: Sorry, we're having a little trouble, it looks like we'll have\n    to get a human involved. Please contact support@hengage.com for help joining the\n    game. Thank you!\n  unrecognized_information_message: Sorry, we're having a little trouble, it looks\n    like we'll have to get a human involved. Please contact support@hengage.com for\n    help joining the game. Thank you!\n  valid_format: \n  invalid_format_message: \n  notify_admins_on_failure: true\n  already_claimed_message: It looks like that account is already claimed. Please try\n    a different employee ID, or contact support@hengage.com for help.\n"], ["updated_at", Tue, 29 Oct 2013 13:54:34 EDT -04:00]]
   (4.4ms)  COMMIT
