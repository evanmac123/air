Airbo 🎉
========
[![Code Climate](https://codeclimate.com/repos/55e48aaee30ba07a20000264/badges/c3777803cac110be5c21/gpa.svg)](https://codeclimate.com/repos/55e48aaee30ba07a20000264/feed) [![Test Coverage](https://codeclimate.com/repos/55e48aaee30ba07a20000264/badges/c3777803cac110be5c21/coverage.svg)](https://codeclimate.com/repos/55e48aaee30ba07a20000264/coverage) [![Build Status](https://semaphoreci.com/api/v1/projects/ba420932-a062-4cec-916a-fedd904d027a/966697/shields_badge.svg)](https://semaphoreci.com/airbo/hengage)


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

    user = User.new({name: 'Joe Blow', password: 'joeblow', password_confirmation: 'joeblow', email: 'joe@blow.com', is_site_admin: true, accepted_invitation_at: Date.today})
    user.save


### Environment Variables

Make sure to set these vars as appropriate. You can ignore the ones marked as Heroku Only in your local environment

| Var                                             |Value                                | Notes                              |
| ------------------------------------------------|-------------------------------------| -----------------------------------|
|APP_HOST                                         |[HOST]                               | Rails Configuration Option         |
|APP_S3_BUCKET                                    |[BUCKET_NAME]                        | Default S3 Bucket                  |
|AVATAR_BUCKET                                    |[BUCKET_NAME]                        | User Avatar Bucket                 |
|AWS_ACCESS_KEY_ID                                |[KEY]                                | Primary AWS access key for images                                                                                             and attachments                    |
|AWS_BULK_UPLOAD_ACCESS_KEY_ID                    |[KEY]                                | Bulk upload specific AWS key       |
|AWS_BULK_UPLOAD_SECRET_ACCESS_KEY                |[SECRET]                             | Bulk upload specific AWS secret    |
|AWS_SECRET_ACCESS_KEY                            |[KEY]                                | Primary AWS secret                 |
|<sub>BILLING_INFORMATION_ENTERED_NOTIFICATION_ADDRESS</sub> |team@airbo.com                       | Address where notifications of                                                                                                 Stripe billing details updates are sent                               |
|BOARD_CREATED_NOTIFICATION_ADDRESS               |team@airbo.com                       | Address where notifications of                                                                                                 board creation are sent            |
|BULK_UPLOADER_BUCKET                             |[BUCKET NAME]                        | Location on S3 where uploaded census                                                                                           files are stored                   |
|BULK_UPLOAD_NOTIFICATION_ADDRESS                 |team@airbo.com                       | Address where notifications of user                                                                                           census file uploads are sent       |
|DATABASE_URL                                     |[URL                                 | Heroku config pointing to DB       |
|<sub>DEFAULT_INVITE_DEPENDENT_EMAIL_BODY</sub>             |[BODY]                               | Default email body for invite spouse                                                                                           feature                            |
|<sub>DEFAULT_INVITE_DEPENDENT_SUBJECT_LINE</sub>           |[SUBJECT]                            | Default email subject for invite                                                                                               spouse feature                     |
|EMAIL_HOST                                       |[HOST]                               | Set host var so sendgrid can                                                                                                   properly set email links that point                                                                                           to the correct environment (dev,                                                                                               staging or production)             |
|EMAIL_PROTOCOL                                   |https                                | Sets to http or https so sendgrid                                                                                             can properly create email links                                                                                               in each  environment (dev,                                                                                                     staging or production)             | 
|ERROR_PAGE_URL                                   |[AWS_ERR_BASE]/503.html              | AWS hosted error page URL          |
|FLICKR_KEY                                       |[KEY]                                | Flickr API key used in image search                                                                                           (to be removed?) |
|FLICKR_SECRET                                    |[SECRET                              | Flickr API secrect usded in image                                                                                             search (to be removed?)            |
|FOG_DIRECTORY                                    |[BUCKET   ]                          | AWS Bucket setting used by                                                                                                     CarrierWave gem                    |
|FOG_PROVIDER                                     |AWS                                  | Setting used by CarrierWave gem    |
|HEROKU_APP_NAME                                  |[APP_NAME]                           | Heroku Specfic Setting             | 
|IMAGE_PROVIDERS                                  |Pixabay                              | Comma separated list of image                                                                                                 services used by image search                                                                                                 feature                            |
|LOG_LEVEL                                        |INFO                                 | Heroku logging config              |
|MAINTENANCE_PAGE_URL                             |[AWS_ERR_BASE]/down_for_maintenance.html| AWS hosted maintenance page URL |
|MAX_SELECTORS_DEFAULT                            |3072                                 | Used by css splitter to limit # CSS                                                                                           selectors per file for IE9                                                                                                     Compatibility                      |
|MIXPANEL_API_KEY                                 |[KEY_ID]                             | Mixpanel API Access Settings       |
|MIXPANEL_API_SECRET                              |[SECRET]                             | Mixpanel API Access Settings       |
|MIXPANEL_EXCLUDED_ORGS                           |[IDS]                                | Comma separated list of Orgs to                                                                                               exclude from MixPanel tracking     |
|MIXPANEL_TOKEN                                   |[TOKEN]                              | Mixpanel API Access Settings       |
|MONGOHQ_URL                                      |[URL]                                | MONGO Datbase URL                  |
|RACK_ENV                                         |[ENV NAME]                           | Used to distinguish staging and                                                                                               development environments in                                                                                                   applicaiton code from the true                                                                                                 production environment onHeroku                                                                                               since RAILS_ENV always equals                                                                                                 "production"                       |
|RAILS_ENV                                        |[ENV NAME]                           | Determines Rails app run mode                                                                                                 development, test, or production   |
|REDISTOGO_URL                                    |[URL]                                | Redis DB URL via Heroku            |
|S3_LOGO_BUCKET                                   |hengage-logos-development            | AWS S3 Bucket where board logos are                                                                                           stored                             |
|SENDGRID_PASSWORD                                |[PWD]                                | Heroku Addon assigned pwd for                                                                                                 sendgrid                           |
|SENDGRID_USERNAME                                |[USER]                               | Heroku Addon assigned login for                                                                                               sendgrid                           |
|STRIPE_API_PRIVATE_KEY                           |[KEY]                                | Stripe account credentials         |
|STRIPE_API_PUBLIC_KEY                            |[KEY]                                | Stripe account credentials         |
|TILE_BUCKET                                      |hengage-tiles-development            | AWS S3 Bucket where tile images are                                                                                           stored                             |
|TWILIO_ACCOUNT_SID                               |                                     | Twilio account credentials         |
|TWILIO_AUTH_TOKEN                                |                                     | Twilio account credentials         |
|TWILIO_PHONE_NUMBER                              |                                     | Twilio Phone number for SMS        |
|TZ                                               |                                     | Rails application TimeZone for                                                                                                 Heroku                             |
|USE_GA                                           |TRUE/FALSE                           | Determines if Google Analytics                                                                                                 javascript should be included in                                                                                               page layout                        |

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

Our CI runs this exact script after every push to github

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

  * Option 1: `script/deploy_production`
      * This:
        1. runs `git push production development:master`
        2. runs `heroku restart -a hengage`
        3. runs `heroku run rake db:migrate -a hengage`
        4. runs `script/airbrake_deploy_production`

  * Option 2: `git push production development:master && heroku restart -a hengage && heroku run rake db:migrate -a hengage`
    * Set deploy for Airbrake:
      1. Make sure `AIRBRAKE_PRODUCTION_PROJECT_ID` and `AIRBRAKE_PRODUCTION_API_KEY` ENV vars are set.
      2. `script/airbrake_deploy_production`

# Application Behaviors 


## File and Image Storage

The application uses a couple file storage strategies. All file assets including images are stored on S3. What is different is how the assets get uploaded to S3

### Paperclip
1. Tile Images:  Paperclip client side direct to S3 upload using jquery-fileupload-rails gem
2. Client logos and Avatars are stored on S3 using server side upload

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
<tr>
<td>Contract Renewer</td> <td>admin:reports:financials:renewals</td> <td>Renews any unrenewed contracts that are set expire in 30 Days or less </td>
</tr>
<tr>
<td>Daily and Weekly Customer Success KPIs</td> <td>admin:reports:financials:customer_success:build_daily</td> <td>Creates the weekly and monthly  customer success KPIS using most recent data</td>
</tr>
<tr>
<td>Daily and Weekly Customer Success KPIs</td> <td>admin:reports:financials:build_daily</td> <td>Creates the weekly and monthly financials  KPIS using most recent data. Has a dependency on the Contract renewals</td>
</tr>
</tbody>
</table>

## Weekly Automated Processes
* note: Heroku Scheduler does not have a setting for running jobs on a weekly basis. The job itself runs daily but will exit automatically if the weekday is not Monday.
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




