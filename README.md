Airbo ☁️
========

[![Build Status](https://semaphoreci.com/api/v1/projects/da66a2f8-2a2d-4768-b146-ce4be4f0e216/1857780/badge.svg)](https://semaphoreci.com/airbo/airbo)

[![Maintainability](https://api.codeclimate.com/v1/badges/6c71ef08e7a18ac5421e/maintainability)](https://codeclimate.com/repos/59fcddd7562e40028b0004ec/maintainability)

[![Test Coverage](https://api.codeclimate.com/v1/badges/6c71ef08e7a18ac5421e/test_coverage)](https://codeclimate.com/repos/59fcddd7562e40028b0004ec/test_coverage)

# About 🎈

Airbo is a Rails 4 application utilizing PostgreSQL, Redis and ElasticSearch on the backend. Rails is propping up a React single-page frontend architecture using the Ruby gem webpacker.

There is still legacy code being utilized through the asset pipeline. This is comprised mostly of jQuery. As we continue to migrate the application over to a more modern ecosystem, legacy code will continue to be phased out and ultimately removed. Do not remove any legacy code without first speaking with the Lead Engineer.

# Developer Machine Setup 💻

## Installing the Environment Essentials

- Install XCode through the App Store
    - After it is installed, in the terminal, select the tools and agree to the terms
      ```
        sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
        sudo xcodebuild -license
      ```
- Install homebrew
        /usr/bin/ruby -e "$(curl -fsSL [https://raw.githubusercontent.com/Homebrew/install/master/install](https://raw.githubusercontent.com/Homebrew/install/master/install))"
- Install wget using Homebrew

    `brew install wget`

- Install Redis CLI using wget

        wget http://download.redis.io/redis-stable.tar.gz
        tar xvzf redis-stable.tar.gz
        cd redis-stable
        make

- Copy Redis CLI to bin

        sudo cp src/redis-server /usr/local/bin/
        sudo cp src/redis-cli /usr/local/bin/

- Install Java8 using Homebrew

    `brew cask install homebrew/cask-versions/java8`

- Install elasticsearch using Homebrew

        brew install elasticsearch
        brew services start elasticsearch

- Install rvm (ruby version manager)

    `\curl -sSL [https://get.rvm.io](https://get.rvm.io/) | bash -s stable --ruby`
  - *NOTE*: You do not have to use rvm, if you prefer rbenv or any other Ruby version manager feel free to install that.

- Install nvm (node version manager)

        curl -o- [https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh](https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh) | bash

- Use NVM to install our version of node.js (this will also install npm)

    `nvm install 10.1.0`

- Install yarn using npm

    `npm install -g yarn`

- Create ssh key for GitHub

        ssh-keygen -t rsa -b 4096 -C "your@email.com"
        pbcopy < ~/.ssh/id_rsa.pub

- Clone down the Airbo repository

    `git clone [git@github.com](mailto:git@github.com):theairbo/hengage.git`

- CD into the directory and install the required ruby with RVM

        cd hengage/
        rvm install "ruby-2.3.5"

- Install bundler with ruby-2.3.5

    `gem install bundler`

- Homebrew install LibXML2 required by `libxml-ruby`

    `brew install libxml2`

- Install `libxml-ruby` gem linking to the homebrew installed libxml (OSX now has its own version which will mess everything up if it's not manually linking to the homebrew version)

        gem install libxml-ruby -v '3.0.0' -- --with-xml2-config=/usr/local/Cellar/libxml2/2.9.8/bin/xml2-config --with-xml2-dir=/usr/local/Cellar/libxml2/2.9.8/ --with-xml2-lib=/usr/local/Cellar/libxml2/2.9.8/lib/ --with-xml2-include=/usr/local/Cellar/libxml2/2.9.8/include/

    - *NOTE*: Version 2.9.8 is what I installed, but that version may change in the future as improvements are made. It must link to the directory that you install.
- Homebrew install posgreSQL

        brew install postgresql
        brew services start postgresql

- Install all of the gem dependencies (run this command inside the project's directory)

    `bundle install`

- Install all JS dependencies (run this command inside the project's directory)

    `yarn install`

- Add the development secrets to the hengage directory
    - Chat with the lead engineer for the credentials
- Create and migrate the database

        rake db:create
        rake db:schema:load
        rake db:migrate
        rake db:test:prepare

- Launch the application (two terminal shells required)
    - First shell: `yarn start`
    - Second shell: `rails s`

Congratulations! Your local development environment is set up. This will be enough to start developing new features and pushing that code up to our GitHub repository.

Below, we will further integrate the local development environment into our staging and production environments.

## Connecting the Dev Environment with the World

- Install the Heroku CLI using Homebrew

    `brew install heroku/brew/heroku`

    - When Homebrew is finished installing, follow the commands onscreen for Heroku's "autocomplete" process
- Install Heroku's account manager using it's CLI

    `heroku plugins:install heroku-accounts`

- Add your Heroku account to the account manager

    `heroku accounts:add airbo`

    - Follow onscreen prompts and enter your Airbo credentials
- Add git remotes for staging and production environments

        git remote add staging [git@heroku.com](mailto:git@heroku.com):hengage-staging.git
        git remote add production [git@heroku.com](mailto:git@heroku.com):hengage.git

- Fetch sanitized production data dump

    `./lib/environment_sync prep`

- Seed local development database with the production data dump (two shells required)
    - First shell (launch background workers): `yarn start`
    - Second shell (seed it): `./lib/environment_sync development`

    *NOTE*: This can be a shaky process initially with a lot of headaches. Common pitfalls include:

      - Redis must be installed and running (see Installing Local Dev Environment)
      - Elasticsearch must be installed and running (see Installing Local Dev Environment)

# Launching a Local Server

## Commands

Airbo takes two shells to run all of the processes required by the application.

The first shell runs Rails' standard server. The command `rails s` launched Rails' server which can be accessed in your browser at `http://localhost:3000`. This shell processes all Rails processes including most database calls, the Rails router, controllers, etc.

The second shell runs all of the background workers and processes. The command `yarn start` launches the Redis server, ElasticSearch, Webpack Dev Server, Rails' background workers and the tail of the Rails' logs. These background processes and servers are required for almost all functionality in the application.

## Running the tests locally

`bundle exec rspec -fd; bundle exec rspec --only-failures`

This will run all tests and then rerun failures one time. Our CI runs this exact script after every push to GitHub, and we rarely run it on our local machines.

# Git Workflow and Committing Code

Our entire Git Workflow is documented in [Notion](https://www.notion.so/airbo/Airbo-Git-Workflow-7ba6635d88b6449e898ca0284f1cc5ce). Please read this carefully before submitting any pull requests. Any PR made that does not follow the patterns described will be rejected.

## Pre-Commit Hooks
There are multiple pre-commit hooks configured in `package.json` that are meant to help enforce code quality and consistency.

1. [Rubocop](https://github.com/bbatsov/rubocop) will run on every `.rb` you attempt to commit and make automatic syntax changes.
2. [Reek](https://github.com/troessner/reek) will run on every `.rb` you attempt to commit and make provide a list of warnings that prevent you from committing (if they exist).  Ideally, you would fix all warning before committing, but sometimes this is unrealistic (i.e. you are dealing with a legacy file that has many warnings).  If warnings are not related to the code you are committing, you may skip the checks.
3. [Prettier](https://github.com/prettier/prettier) will run and make automatic syntax changes to all `.js, .css, .scss` files committed.
4. [StyleLint](https://github.com/stylelint/stylelint) will run and make automatic syntax changes to all `.css, .scss` files committed.
5. [ESLint](https://eslint.org/) (ES5 configuration) will run on all `.js` files that are managed by the Asset Pipeline (i.e. all `.js` that is in `app/assets/**/*`). The config for this ESLint process is in `app/assets/javascripts/.eslintrc`.
6. [ESLint](https://eslint.org/) (ESNext configuration) will run on all `.js` files that are managed by the Webpacker (i.e. all `.js` that is in `app/javascript/**/*`). The config for this ESLint process is in `app/javascript/.eslintrc`.

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

# Notes

## Deploying to Heroku

A Heroku release task will run migrations and restart the dynos automatically

A Heroku release task will aslo run any configured deploy hooks. Currently, there is a deploy hook to notify Airbrake of the deploy.

We use the Node Buildpack as well as the Ruby Buildpack.  Although the Ruby Buildpack runs `yarn install` if the `gem webpacker` is present, it does not run it before normal asset compilation, which we need in order to include yarn dependencies in css and js files managed by the Asset Pipeline. Therefore, we use the Node Buildpack to install yarn dependencies prior to Asset Pipeline's precompile. This is unfortunate because it means we run `yarn install` twice (though it's cached and not a big deal), but this is an ongoing Rails/Heroku issue. We can check back in the future for a better resolution.

## Additional Resources

All of this documentation along with an example `.bash_profile` configuration can be found within [Airbo's Technology Notion Page](https://www.notion.so/airbo/Operations-Documentation-5b7eac13676048ac9fe18886aac514a6). Please update and the documentation as needed and submit pull requests for this README to ensure we lessen headaches for our future developers. 😀

## Active Domains
| Name | Purpose | Registrar | Primary Contact | Secondary Contact | Auto renew? | Expiration/Auto Renew Month |
|--------------|:---------------------------:|--------------------:|-----------------|--------------------|-------------|-----------------------------|
| airbo.com | Primary Domain | www.enom.com | vlad@airbo.com | sysadmin@airbo.com | true | March |
| ourairbo.com | Sendgrid white label domain | www.iwantmyname.com | vlad@airbo.com | sysadmin@airbo.com | true | November |
