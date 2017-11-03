Airbo 🎉
========
[![Maintainability](https://api.codeclimate.com/v1/badges/6c71ef08e7a18ac5421e/maintainability)](https://codeclimate.com/repos/59fcddd7562e40028b0004ec/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/6c71ef08e7a18ac5421e/test_coverage)](https://codeclimate.com/repos/59fcddd7562e40028b0004ec/test_coverage) [![Build Status](https://semaphoreci.com/api/v1/projects/da66a2f8-2a2d-4768-b146-ce4be4f0e216/1607679/badge.svg)](https://semaphoreci.com/airbo/airbo)


Developer Machine Setup
------------

### Mac Only
Install [homebrew](http://brew.sh) then do brew install postgres, redis, mongodb, Qt, ImageMagick, elasticsearch

Git should be installed on your Mac if it's not do: brew install git.


#### Install Ruby Manager
Use  [RBENV](https://github.com/rbenv/rbenv) or [CHRUBY](https://medium.com/@heidar/switching-from-rbenv-to-postmodern-s-ruby-install-and-chruby-f0daa24b36e6#.hl85swk6r) if you have need to support multiple ruby versions *

If opting for chruby with ruby-install, you can install ruby 2.0.0 with this command:

    ruby-install -M https://cache.ruby-lang.org/pub/ruby ruby 2.0.0-p645


Airbo App Setup
------------
Get the HEngage source code:

    git clone git@github.com:theairbo/hengage.git

Install the dependent Ruby libraries:

    bundle

Create your development and test databases. (Note: Two distinct steps: 1 for development and 1 for test):

    rake db:create

Load the development database:

    rake db:schema:load

Prepare the test database:

    rake db:test:prepare

Download the most recent db backup from Heroku:

    script/environment_sync prep

Populate your development database with a sanitized cut of production:

    script/environment_sync development

Airbo employee users (site_admin) are not sanitized in the previous command, so you will be able to login to your dev environement with your production credentials.

### Environment Variables

Production ENV Vars:

Var                                              |Value                     | Notes
-------------------------------------------------|--------------------------| ------------------------------------------------------
AIRBRAKE_API_KEY                                 | [KEY]                     | Airbrake API Access
AIRBRAKE_PROJECT_ID                              | [ID]                      | Airbrake API Access
APP_HOST                                         | [HOST]                    | Rails Configuration Option
APP_S3_BUCKET                                    | [BUCKET_NAME]             | Default S3 Bucket
AVATAR_BUCKET                                    | [BUCKET_NAME]             | User Avatar Bucket
AWS_ACCESS_KEY_ID                                | [KEY]                     | Primary AWS access key for images and attachments
AWS_BULK_UPLOAD_ACCESS_KEY_ID                    | [KEY]                     | Bulk upload specific AWS key
AWS_BULK_UPLOAD_SECRET_ACCESS_KEY                | [SECRET]                  | Bulk upload specific AWS secret
AWS_SECRET_ACCESS_KEY                            | [KEY]                     | Primary AWS secret
BILLING_INFORMATION_ENTERED_NOTIFICATION_ADDRESS | team@airbo.com            | Address where notifications of Stripe billing details updates are sent
BOARD_CREATED_NOTIFICATION_ADDRESS               | team@airbo.com            | Address where notifications of board creation are sent
BULK_UPLOADER_BUCKET                             | [BUCKET NAME]             | Location on S3 where uploaded census files are stored
BULK_UPLOAD_NOTIFICATION_ADDRESS                 | team@airbo.com            | Address where notifications of user census uploads are sent
DATABASE_URL                                     | [URL]                     | Heroku config pointing to DB
DEFAULT_INVITE_DEPENDENT_EMAIL_BODY              | [BODY]                    | Default email body for invite spouse feature
DEFAULT_INVITE_DEPENDENT_SUBJECT_LINE            | [SUBJECT]                 | Default email subject for invite spouse feature
DELIGHTED_KEY                                    | [KEY]                     | Delighted is our NPS service
ELASTICSEARCH_URL                                | [URL]                     | Elastic Search DB URL. This ENV var is not called explicitly in the app as Searchkick defaults to looking up the DB URL with this var.
EMAIL_HOST                                       | [HOST]                    | Set host var so sendgrid can properly set email links that point to the correct environment (dev, staging or production)
EMAIL_PROTOCOL                                   | https                     | Sets to http or https so sendgrid can properly create email in each  environment (dev, staging or production)
ERROR_PAGE_URL                                   | [URL]                     | AWS hosted error page URL
FOG_DIRECTORY                                    | [BUCKET]                  | AWS Bucket setting used by CarrierWave gem
FOG_PROVIDER                                     | AWS                       | Setting used by CarrierWave gem
GAME_CREATION_REQUEST_ADDRESS                    | team@airbo.com            | Email recipient to notify new boards(deprecate for better solution)
HEROKU_APP_NAME                                  | [APP_NAME]                | Heroku Specfic Setting
IMAGE_PROVIDERS                                  | Pixabay                   | Comma separated list of image services used by image search feature
INTERCOM_API_SECRET                              | [SECRET]                  | Intercom API Access Settings
INTERCOM_API_KEY                                 | [KEY]                     | Intercom API Access Settings
INTERCOM_APP_ID                                  | [ID]                      | Intercom API Access Settings
INTERCOM_OLD_USERS_SEGMENT_IDS                   | [SEGMENT_ID]              | Intercom Segment ID used to purge stale intercom users
LOG_LEVEL                                        | WARN                      | Heroku logging config
MAINTENANCE_PAGE_URL                             | [URL]                     | AWS hosted maintenance page URL
MAX_SELECTORS_DEFAULT                            | 3072                      | Used by css splitter to limit # CSS selectors per file for Compatibility
MIXPANEL_API_KEY                                 | [KEY_ID]                  | Mixpanel API Access Settings
MIXPANEL_API_SECRET                              | [SECRET]                  | Mixpanel API Access Settings
MIXPANEL_EXCLUDED_ORGS                           | [IDS]                     | Comma separated list of Orgs to exclude from MixPanel tracking (remove?)
MIXPANEL_TOKEN                                   | [TOKEN]                   | Mixpanel API Access Settings
MONGOHQ_URL                                      | [URL]                     | MONGO Datbase URL                  |
RACK_ENV                                         | [ENV NAME]                | Used to distinguish staging and development environments in applicaiton code from the true production environment onHeroku since RAILS_ENV always equals "production"
RAILS_ENV                                        | [ENV NAME]                | Determines Rails app run mode development, test, or production
REDIS_APP                                        | [URL]                     | Redis DB URL via Heroku
REDIS_BULK_UPLOAD                                | [URL]                     | Redis DB URL via Heroku
REDIS_CACHE                                      | [URL]                     | Redis DB URL via Heroku
SCOUT_KEY                                        | [KEY]                     | Scout APM Access
SCOUT_LOG_LEVEL                                  | WARN                      | Scount log level
SCOUT_MONITOR                                    | true                      | Scout monitor feature flag
SCOUT_NAME                                       | Airbo (production)        | Scout App name
S3_LOGO_BUCKET                                   | hengage-logos-development | AWS S3 Bucket where board logos are stored
SENDGRID_PASSWORD                                | [PWD]                     | Heroku Addon assigned pwd for sendgrid
SENDGRID_USERNAME                                | [USER]                    | Heroku Addon assigned login for sendgrid
STRIPE_API_PRIVATE_KEY                           | [KEY]                     | Stripe account credentials
STRIPE_API_PUBLIC_KEY                            | [KEY]                     | Stripe account credentials
TILE_BUCKET                                      | [BUCKET]                  | AWS S3 Bucket where tile images are stored
TWILIO_ACCOUNT_SID                               | [ID]                      | Twilio account credentials
TWILIO_AUTH_TOKEN                                | [TOKEN]                   | Twilio account credentials
TWILIO_PHONE_NUMBER                              | [NUMBER]                  | Twilio Phone number for SMS
TZ                                               | EST                       | Rails application TimeZone for Heroku
USE_GA                                           | TRUE/FALSE                | Determines if Google Analytics javascript should be included in page layout

Required Development ENV Vars:

Var                                              |Value        | Notes                                                          
-------------------------------------------------|-------------| ---------------------------------------------------------------
AIRBRAKE_API_KEY                                 | [KEY]               | Dev Airbrake API Access                                        
AIRBRAKE_PROJECT_ID                              | [ID]                | Dev Airbrake API Access                                        
AIRBRAKE_PRODUCTION_API_KEY                      | [KEY]               | Airbrake Production API Access for deploy tracking             
AIRBRAKE_PRODUCTION_PROJECT_ID                   | [ID]                | Airbrake Production API Access for deploy tracking             
AWS_ACCESS_KEY_ID                                | [ID]                | AIM User AWS Access Key                                        
AWS_BULK_UPLOAD_ACCESS_KEY_ID                    | [ID]                | AIM User AWS Access Key                                        
AWS_SECRET_ACCESS_KEY                            | [KEY]               | AIM User AWS Secret Access Key                                 
AWS_BULK_UPLOAD_SECRET_ACCESS_KEY                | [KEY]               | AIM User AWS Secret Access Key                                 
IMAGE_PROVIDERS                                  | pixabay             | Default image provider for image search
INTERCOM_API_SECRET                              | [SECRET]            | Dev Intercom API Access                                        
INTERCOM_API_KEY                                 | [KEY]               | Dev Intercom API Access                                        
INTERCOM_APP_ID                                  | [ID]                | Dev Intercom API Access                                        
INTERCOM_OLD_USERS_SEGMENT_IDS                   | [IDS]               | Intercom segment necessary for running Intercom purge script   
MIXPANEL_API_KEY                                 | [KEY]               | Dev Mixpanel API Access                                        
MIXPANEL_API_SECRET                              | [SECRET]            | Dev Mixpanel API Access                                        
PIXABAY_KEY                                      | [KEY]               | Dev Pixabay API Access                                         
SCOUT_DEV_TRACE                                  | true                | Activate Scout Dev Trace                                       
STRIPE_API_PRIVATE_KEY                           | [KEY]               | Dev Stripe API Access                                          
STRIPE_API_PUBLIC_KEY                            | [KEY]               | Dev Stripe API Access                                          

#### Notes
1. IE9 cannot handle more than 4096 css selectors per css file. We use css splitter to split large css files into IE9 digestable chunks here we set the max number of selectors to 3072.  This is below the 4096 limit because there appears to be a file size limit in IE9 as well but that has been hard to confirm. Setting the max selectors to 3072 hopefully keeps the file size below the limit if it exists.

2. AWS_URL = https://s3.amazonaws.com
3. AWS_ERROR_BASE = https://s3.amazonaws.com/heroku_error_page

### Running App locally

To run the app locally:

    1. `script/airbo_dev_up` will start workers, redis, and elastic search as well as serve as a log.
    2. `rails s`

### Running the tests locally

  `bundle exec rspec -fd -t ~broken:true; bundle exec rspec --only-failures`

This will run all tests ignoring those flaggged as broken (to be removed) and then rerun failures one time.

Our CI runs this exact script after every push to github.

Committing Code
---------------

### Airbo Git Workflow


1. Create a feature branch off of `development`.  The branch should be prefixed with an issue number of the first issue you are working on in the branch.  Ex: `git checkout -b 111_example_feature_branch`
2. Push your feature branch to GitHub and create a pull request.  This will trigger Semaphore and CodeClimate to run checks as you develop and let the team know what you are working on.  Prefix the name of the pull request with 'WIP' while your are still working on the branch (work in progress).
3. Push to GitHub as you develop in order to continue running checks.  If you are working on a branch for an extended period of time, periodically pull `development` and rebase `developmet` onto your feature branch. Ex: `git rebase development 111_example_feature_branch`
4. When development is complete, rebase `developmet` onto your feature branch and squash commits to a single commit with a commit message that details the issues that will be closed. Remove 'WIP' from the pull request name. When pushing to GitHub after you squash your commits, you will have to force push.
    ```
    git rebase development 111_example_feature_branch
    git rebase -i development 111_example_feature_branch
    git push origin 111_example_feature_branch -f
    ```

5. Before merging your pull request:
  * Make sure Semaphore passes
  * Make sure all the CodeClimate checks pass
  * Ask for code review on your pull request if needed
  * Deploy to Staging and QA
6. Merge pull requests from the GitHub GUI and delete your feature banch in the same GUI after merging.


### Add Heroku Git Remotes for Staging and production environments

    git remote add staging git@heroku.com:hengage-staging.git
    git remote add production git@heroku.com:hengage.git

### Deploying


To deploy to staging:

  * Option 1: Deploy from Semaphore
  * Option 2: `git push staging ${branch}:master -f`

To deploy to production:

  * Make sure `AIRBRAKE_PRODUCTION_PROJECT_ID` and `AIRBRAKE_PRODUCTION_API_KEY` ENV vars are set.

  * Run `script/deploy_production`
      * This:
        1. runs `git push production development:master`
        2. runs `heroku run rake db:migrate -a hengage`
        3. runs `heroku restart -a hengage`
        4. runs `script/airbrake_deploy_production`

## Active Domains
<table>
<thead>
<tr>
<td>Name</td>
<td>Purpose</td>
<td>Registrar</td>
<td>Notes</td>
</tr>
</thead>
<tbody>
<tr>
<td>airbo.com</td>
<td>Primary Domain</td>
<td>www.enom.com</td>
<td>
Primary Contact: Vlad
Secondary Contact: sysadmin@airbo.com
Expiration:  March 14, 2018
Auto Renew: True
Auto Renew Date:  ?
</td>
<tr>
<td>air.bo</td>
<td>Legacy domain name.</td>
<td>www.europeregistry.com</td>
<td>Primary Contact: Vlad
Secondary Contact: sysadmin@airbo.com
Expiration:  December 12, 2017
Auto Renew: True
Auto Renew Date:  ?
</td>
</tr>
<tr>
<td>ourairbo.com</td>
<td>Sendgrid white label domain</td>
<td>iwantmyname.com</td>
<td>Primary Contact: Vlad
Secondary Contact: ?
Expiration:  December 17, 2017
Auto Renew: Yes
Auto Renew Date:  November 9, 2017
</td>
</tr>
<tbody>
<table>

# Application Behaviors




## File and Image Storage

The application uses a couple file storage strategies. All file assets including images are stored on S3. What is different is how the assets get uploaded to S3.

### Paperclip
1. Tile Images:  Paperclip client side direct to S3 upload using jquery-fileupload-rails gem
2. Other images (client logos, avatars, channel images, etc.) are stored on S3 using server side upload

### CarrierWave
1. Census Files: Use a form backed by CarrierWave Direct and Fog gems.


### Other
CSS assets and images are also stored on S3 using the asset-sync gem and also have a dependency on the fog gem

## Daily Automated Processes

<table>
<thead>
<tr>
<th>Job Name</th> <th>Rake Task </th> <th>Notes  </th>
</tr>
</thead>
<tbody>
<tr>
<td>Tile Digests Followup Mailer</td> <td>:cron</td> <td>Sends any scheduled Tile Digests follow up emails</td>
</tr>
</tbody>
</table>

## Weekly Automated Processes
Heroku Scheduler does not have a setting for running jobs on a weekly basis. The job itself runs daily but will exit automatically if the weekday is not Monday.
<table>
<thead>
<tr>
<th>Job Name</th> <th>Rake Task </th> <th>Notes  </th>
</tr>
</thead>
<tbody>
<tr>
<td>Weekly Activity Report</td> <td>:reports:client_admin:weekly_activity</td> <td>Sends board activity report to client admins </td>
</tr>
</tbody>
</table>

## AWS
https://hengage.signin.aws.amazon.com/console
