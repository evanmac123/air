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

