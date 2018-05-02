Airbo 🎉
========

[![Build Status](https://semaphoreci.com/api/v1/projects/da66a2f8-2a2d-4768-b146-ce4be4f0e216/1857780/badge.svg)](https://semaphoreci.com/airbo/airbo)

[![Maintainability](https://api.codeclimate.com/v1/badges/6c71ef08e7a18ac5421e/maintainability)](https://codeclimate.com/repos/59fcddd7562e40028b0004ec/maintainability)

[![Test Coverage](https://api.codeclimate.com/v1/badges/6c71ef08e7a18ac5421e/test_coverage)](https://codeclimate.com/repos/59fcddd7562e40028b0004ec/test_coverage)

Developer Machine Setup
------------

### Mac Only
Add [this](https://github.com/theairbo/hengage/wiki/.laptop.local) file to `~/.laptop.local` and then run [this](https://github.com/thoughtbot/laptop) laptop setup script.

Add provided environment variables (see Environment Variables section).

#### Ruby Version Manager
We use [asdf](https://github.com/asdf-vm/asdf) as our version manager for all langs.

#### Setting Up MongoDB
* After downloading Mongo, create the “db” directory. This is where the Mongo data files will live. You can create the directory in the default location by running `mkdir -p /data/db`
* Make sure that the /data/db directory has the right permissions by running ``sudo chown -R `id -un` /data/db``

Airbo App Setup
------------
1. Get the Airbo source code:

    `git clone git@github.com:theairbo/hengage.git`

2. Install the dependent Ruby and JS libraries:

    `bundle install`

    `yarn install`

3. Ensure you can boot up the background script `lib/airbo_dev_up`.  Common issues here include already having Redis or ElasticSearch running already.

4. Create your development and test databases. (Note: Two distinct steps: 1 for development and 1 for test):

    `rake db:create`

5. Load the development schema:

    `rake db:schema:load`

6. Prepare the test database:

    `rake db:test:prepare`

7. Download the most recent db backup from Heroku:

    `lib/environment_sync prep`

8. Run `lib/airbo_dev_up`

9. Populate your development database with a sanitized cut of production:

    `lib/environment_sync development`

Airbo employee users (site_admin) are not sanitized in the previous command, so you will be able to login to your dev environement with your production credentials.

### Environment Variables
Add necessary environment variables in a `.env` file using the `.dev_template.env` as reference.

We have historically just used a similar bash alias/script as the following to load env vars: `alias work="cd ~/workspace/airbo/hengage; source .env; heroku accounts:set airbo"`.

### Running App locally

To run the app locally:

1. `lib/airbo_dev_up` will start workers, redis, and elastic search as well as serve as a log.
2. `rails s`

### Running the tests locally

`bundle exec rspec -fd; bundle exec rspec --only-failures`

This will run all tests and then rerun failures one time.
Our CI runs this exact script after every push to githuh and we rarely run it on our local machines.

## Committing Code

### Airbo Git Workflow

1. Create a feature branch off of `master`.  The branch should be prefixed with an issue number of the first issue you are working on in the branch.  Ex: `git checkout -b 111_example_feature_branch`
2. Push your feature branch to GitHub and create a pull request.  This will trigger Semaphore and CodeClimate to run checks as you develop and let the team know what you are working on.  Prefix the name of the pull request with 'WIP' while your are still working on the branch (work in progress).
3. Push to GitHub as you develop in order to continue running checks.  If you are working on a branch for an extended period of time, periodically pull `master` and rebase `master` onto your feature branch. Ex: `git rebase master 111_example_feature_branch`
4. When development is complete, rebase `master` onto your feature branch and squash commits to a single commit with a commit message that details the issues that will be closed. Remove 'WIP' from the pull request name. When pushing to GitHub after you squash your commits, you will have to force push.
    ```
    git rebase master 111_example_feature_branch
    git rebase -i master 111_example_feature_branch
    git push origin 111_example_feature_branch -f
    ```

5. Before merging your pull request:
  * Make sure Semaphore passes
  * Make sure all the CodeClimate checks pass
  * Ask for code review on your pull request if needed
  * Deploy to Staging and QA
6. Merge pull requests from the GitHub GUI and delete your feature banch in the same GUI after merging.

### Pre-Commit Hooks
There are multiple pre-commit hooks configured in `package.json` that are meant to help enforce code quality and consistency.

1. [Rubocop](https://github.com/bbatsov/rubocop) will run on every `.rb` you attempt to commit and make automatic syntax changes.
2. [Reek](https://github.com/troessner/reek) will run on every `.rb` you attempt to commit and make provide a list of warnings that prevent you from committing (if they exist).  Ideally, you would fix all warning before committing, but sometimes this is unrealistic (i.e. you are dealing with a legacy file that has many warnings).  If warnings are not related to the code you are committing, you may skip the checks.
3. [Prettier](https://github.com/prettier/prettier) will run and make automatic syntax changes to all `.js, .css, .scss` files committed.
4. [StyleLint](https://github.com/stylelint/stylelint) will run and make automatic syntax changes to all `.css, .scss` files committed.
5. [ESLint](https://eslint.org/) (ES5 configuration) will run on all `.js` files that are managed by the Asset Pipeline (i.e. all `.js` that is in `app/assets/**/*`). The config for this ESLint process is in `app/assets/javascripts/.eslintrc`.
6. [ESLint](https://eslint.org/) (ESNext configuration) will run on all `.js` files that are managed by the Webpacker (i.e. all `.js` that is in `app/javascript/**/*`). The config for this ESLint process is in `app/javascript/.eslintrc`.

## Deploying

### Add Heroku account for Airbo
  Use [this repo](https://github.com/heroku/heroku-accounts) as reference.
  * See bash alias in the "Environment Variables" section to auto move to your Airbo Heroku account.

  `heroku accounts:add airbo`

### Add Heroku Git Remotes for Staging and production environments

    `git remote add staging git@heroku.com:hengage-staging.git`
    `git remote add production git@heroku.com:hengage.git`

To deploy to staging:

  * Option 1: Deploy from Semaphore (preferred)
  * Option 2: `git push staging ${branch}:master -f`

To deploy to production:

  * Option 1: Deploy from Semaphore (preferred)
  * Option 2: `lib/deploy_production`

Notes

  * A Heroku release task will run migrations and restart the dynos automatically

  * A Heroku release task will aslo run any configured deploy hooks. Currently, there is a deploy hook to notify Airbrake of the deploy.

  * We use the Node Buildpack as well as the Ruby Buildpack.  Although the Ruby Buildpack runs `yarn install` if the `gem webpacker` is present, it does not run it before normal asset compilation, which we need in order to include yarn dependencies in css and js files managed by the Asset Pipeline. Therefore, we use the Node Buildpack to install yarn dependencies prior to Asset Pipeline's precompile. This is unfortunate because it means we run `yarn install` twice (though it's cached and not a big deal), but this is an ongoing Rails/Heroku issue. We can check back in the future for a better resolution.

## Active Domains
| Name | Purpose | Registrar | Primary Contact | Secondary Contact | Auto renew? | Expiration/Auto Renew Month |
|--------------|:---------------------------:|--------------------:|-----------------|--------------------|-------------|-----------------------------|
| airbo.com | Primary Domain | www.enom.com | vlad@airbo.com | sysadmin@airbo.com | true | March |
| ourairbo.com | Sendgrid white label domain | www.iwantmyname.com | vlad@airbo.com | sysadmin@airbo.com | true | November |

# Application Behaviors

## File and Image Storage

The application uses a couple file storage strategies. All file assets including images are stored on S3. What is different is how the assets get uploaded to S3.

### Paperclip
1. Tile Images: Paperclip client side direct to S3 upload using `jquery-fileupload-rails` gem
2. Other images (client logos, avatars, channel images, etc.) are stored on S3 using server side upload

### CarrierWave
1. Census Files: Use a form backed by CarrierWave Direct and Fog gems.

### Direct to S3
1. Tile Attachments: direct to S3 upload using `jquery-fileupload-rails` gem, but then simply stored as a url ref on the Tile instead of a Paperclip object.

## Automated Processes
We use the Heroku Scheduler add-on to manage cron jobs. Review daily and weekly automated jobs via Heroku.

## AWS
* Login: https://hengage.signin.aws.amazon.com/console

### AWS Services we actively use
* *S3* for file storage
* *CloudFront* as a distributed CDN
* *IAM* for permissions management
