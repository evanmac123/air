H Engage
========

This is the H Engage Rails app.

Laptop setup
------------

First, get your machine set up by following the instructions here:

    [https://github.com/thoughtbot/laptop](Thoughtbot Setup)

If you need a text editor, use Textmate:

    http://macromates.com/

If you use Textmate, set your tabs to "Soft Tabs: 2". This is one of the drop-down options at the very bottom of your window.

Faster workflow
---------------

Set up some git aliases: (~/.gitconfig)

    [alias]
      up = !git fetch origin && git rebase origin/master
      mm = !test `git rev-parse master` = $(git merge-base HEAD master) && git checkout master && git merge HEAD@{1} || echo "Non-fastforward"

Set up some shell aliases: (~/.aliases)

    alias be="bundle exec"
    alias s="bundle exec rspec"
    alias cuc="bundle exec cucumber"

For the aliases to take effect, add this to your ~/.bash_profile:

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

Get the H Engage source code:

    git clone git@github.com:vladig17/hengage.git

Install the dependent Ruby libraries:

    bundle

Create your development and test databases:

    rake db:create

Migrate the development database:

    rake db:migrate

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

