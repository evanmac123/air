Airbo 🎉
========
[![Code Climate](https://codeclimate.com/repos/55e48aaee30ba07a20000264/badges/c3777803cac110be5c21/gpa.svg)](https://codeclimate.com/repos/55e48aaee30ba07a20000264/feed) [![Test Coverage](https://codeclimate.com/repos/55e48aaee30ba07a20000264/badges/c3777803cac110be5c21/coverage.svg)](https://codeclimate.com/repos/55e48aaee30ba07a20000264/coverage) [![Build Status](https://semaphoreci.com/api/v1/projects/ba420932-a062-4cec-916a-fedd904d027a/966697/shields_badge.svg)](https://semaphoreci.com/airbo/hengage)


Developer Machine setup
------------

### Mac
Install [homebrew](http://brew.sh) then do brew install postgres, redis, mongodb, Qt, ImageMagick, elasticsearch 

Git should be installed on your Mac if it's not do: brew install git.


#### Install Ruby Manager
Use  [RBENV](https://github.com/rbenv/rbenv) or [CHRUBY](https://medium.com/@heidar/switching-from-rbenv-to-postmodern-s-ruby-install-and-chruby-f0daa24b36e6#.hl85swk6r) if you have need to support multiple ruby versions *

If opting for chruby with ruby-install, you can install ruby 2.0.0 with this command:

    ruby-install -M https://cache.ruby-lang.org/pub/ruby ruby 2.0.0-p645


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

    user = User.new({name: 'Joe Blow', password: 'joeblow', password_confirmation: 'joeblow', email: 'joe@blow.com', is_site_admin: true, accepted_invitation_at: Date.today})
    user.save


Environment Config VAars
-----------
Make sure to set these vars as appropriate.  Below is for example purpose only

| Var                              |Value                   | Notes                      |
| -------------                    |-------------         | ----- |
|MAX_SELECTORS_DEFAULT             |3072 |IE9 cannot handle more than 4096 css selectors per css file. We use css splitter to split the file into IE9 digestable chunks.        |
|APP_HOST                          |[HOST]        |              |
|APP_S3_BUCKET                     |[BUCKET_NAME] |              |
|AVATAR_BUCKET                     |[BUCKET_NAME] |              |
|AWS_ACCESS_KEY_ID                 |[KEY]         |              |
|AWS_BULK_UPLOAD_ACCESS_KEY_ID     |[KEY]         |              |
|AWS_BULK_UPLOAD_SECRET_ACCESS_KEY |[SECRET]      |              |
|AWS_SECRET_ACCESS_KEY             |[KEY]         |              |
|BILLING_INFORMATION_ENTERED_NOTIFICATION_ADDRESS |team@airbo.com|       |
|BOARD_CREATED_NOTIFICATION_ADDRESS               |team@airbo.com|
|BULK_UPLOADER_BUCKET                             |[BUCKET NAME] |       |
|BULK_UPLOAD_NOTIFICATION_ADDRESS                 |team@airbo.com|
|DATABASE_URL                                     |[URL          |       |
|DEFAULT_DEMO_PARENT_BOARD                        |[BOARD NAME]  |       |
|DEFAULT_INVITE_DEPENDENT_EMAIL_BODY              |[EMAIL BODY]  |       |
|DEFAULT_INVITE_DEPENDENT_SUBJECT_LINE            |[EMAIL SUBJECT]|      | 
|EMAIL_HOST                                       |[HOST]         |      |
|EMAIL_PROTOCOL                                   |https          |      |
|ERROR_PAGE_URL                                   |https://s3.amazonaws.com/heroku_error_page/503.html |     |
|EXPLORE_ENABLED                                  |True                                                |     |
|FLICKR_KEY                                       |[KEY]                                               |     |
|FLICKR_SECRET                                    |[SECRET                                             |     |
|FOG_DIRECTORY                                    |hengage-tiles-development                           |     |
|FOG_PROVIDER                                     |AWS                                                 |     |
|GAME_CREATION_REQUEST_ADDRESS|team@airbo.com     |                                                    |     |
|HEROKU_APP_NAME                                  |hengage-dev                                         |     |     
|HOMEPAGE_BOARD_SLUGS                             |[SLUG_NAMES]                                        |     |
|IMAGE_PROVIDERS                                  |Pixabay                                             | |
|LOG_LEVEL                                        |INFO                                                |  |
|MIXPANEL_API_KEY                                 |[KEY_ID]                                            |  |
|MIXPANEL_API_SECRET                              |[SECRET]                                            |  |
|MIXPANEL_TOKEN                                   |[TOKEN]                                             |  |
|MONGOHQ_URL                                      |[URL]                                               |  |
|MONGOLAB_URI                                     |[URL]                                               |  |
|RACK_ENV                                         |development                                         |  |
|RAILS_ENV                                        |production                                          |  |
|REDISTOGO_URL                                    |[URL]|  |
|S3_LOGO_BUCKET                                   |hengage-logos-development|  |
|S3_TILE_BUCKET                                   |hengage-tiles-development|  |
|SENDGRID_PASSWORD                                |[PWD]|  |
|SENDGRID_USERNAME                                |[USER]|  |
|STRIPE_API_PRIVATE_KEY                           |[KEY]                       |  |
|STRIPE_API_PUBLIC_KEY                            |[KEY]                       |                                  |
|TILE_BUCKET                                      |hengage-tiles-development|                |

Running the app
---------------

To run the app locally:

    1. `script/airbo_dev_up` will start workers, redis, and elastic search as well as serve as a log.
    2. `rails s`

Running the tests
-----------------

Our CI runs with the following script:

  `bundle exec rspec -fd -t ~broken:true; bundle exec rspec --only-failures`

This will run all tests not flagged for removal and then rerun failures one time.


Airbo Git Flow
--------------

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

Add Heroku Git Remotes for Staging and production environments
-----------------------------------

    git remote add staging git@heroku.com:hengage-staging.git
    git remote add production git@heroku.com:hengage.git


Deploying
---------

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

