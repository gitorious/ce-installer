# Upgrading Gitorious from v2 to v3

The following instruction assumes that you have installed Gitorious v2 using the [community edition installer][ce-installer].

## The short version

1. Back up your gitorious installation.

2. Check out the newest version of the ce-installer:

        git clone git@gitorious.org/gitorious/ce-installer.git && cd ce-installer

3. Run the automated upgrade script

        sudo ./upgrade.sh

4. Review the deprecation warnings printed by the upgrade script and update your `/var/www/gitorious/app/config/gitorious.yml` accordingly. You can find an example of valid configuration in `/var/www/gitorious/app/config/gitorious.sample.yml`

5. Profit!

## The longer version

If your installation differs from the standard, it might be impossible for you to upgrade using the automated script. The following instructions should help you in the manual upgrade process.

### Prerequisites

1. Back up your installation.

2. Download the newest version of ce-installer:

        git clone git@gitorious.org/gitorious/ce-installer.git && cd ce-installer

### Upgrade Ruby from 1.8 to 1.9.3 with chruby

Gitorious v3 has switched from Ruby 1.8 to 1.9.3. In the old installation process, Ruby was installed using yum. You will need to uninstall it:

    yum -y remove ruby

We recommend using ruby-install to install Ruby 1.9.3 and chruby to switch between Ruby versions. The ce-installer comes with a script for installing ruby-install, chruby and Ruby 1.9.3:

    # in ce-installer
    ./install-ruby.sh

NOTE: after installing chruby, your shell might not see the chruby command yet. You may need to source the chruby profile.d script first:

    source /etc/profile.d/chruby.sh

### Upgrade Gitorious executables to use chruby

Gitorious v2 used system Ruby, so we need to make sure that all the Gitorious executables are using chruby to pick the correct interpreter.

To run a command with chruby, prefix it with the following:

    /usr/local/bin/chruby-exec ruby-1.9.3-p448 -- <command goes here>

The ce-installer already contains the executable templates in the correct form. You can install them using the following commands:

    # in ce-installer

    ./render_config.rb /vagrant/ce-installer/modules/gitorious/templates/etc/init.d/gitorious-unicorn.erb > /etc/init.d/gitorious-unicorn

    ./render_config.rb /vagrant/ce-installer/modules/resque/templates/etc/init/resque-worker.conf.erb > /etc/init/resque-worker.conf

    cp modules/gitorious/templates/usr/bin/gitorious.erb /usr/bin/gitorious
    chmod +x /usr/bin/gitorious
    rm -f /usr/local/bin/gitorious

### Checkout the v3 version of Gitorious

Now you are ready to update Gitorious code to the latest stable version:

    cd /var/www/gitorious/app

    git fetch --all
    git checkout master -f
    git submodule init
    git submodule update --recursive

### Install dependencies of v3

Gitorious v3 depends on charlock-holmes gem, which in turn depends on libicu, which you will need to install through yum:

    yum -y install libicu-devel patch

Now you can install the gems:

    cd /var/www/gitorious/app

    gem install bundler
    bundle install --deployment --without development test postgres

### Migrate the database

Before you can migrate the database, you will need to update your database.yml config to use mysql2 adapter instead of the old mysql one. You can do that automatically by running the following command:

    cd /var/www/gitorious/app

    sed -i s/mysql\\b/mysql2/ config/database.yml

Now you are ready to migrate:

    RAILS_ENV=production bundle exec rake db:migrate

### Fix invalid data

Some already fixed bugs left the database in inconsistent state. You can run the following rake tasks to fix those issues:

    cd /var/www/gitorious/app 

    RAILS_ENV=production bundle exec rake fix_dangling_comments fix_dangling_memberships \ 
      fix_missing_wiki_repos fix_dangling_committerships fix_dangling_projects \ 
      fix_system_comments fix_dangling_events fix_dangling_repositories \ 
      fix_dangling_favorites fix_missing_repos 
}

### Fix deprecated configuration options

We changed the names of some configuration options and removed others. You will see the deprecation warnings when you push to any repository, but the easier way to see them is to run:

    cd /var/www/gitorious/app 
    RAILS_ENV=production bundle exec rails r ''

Compare your gitorious.yml with the provided gitorious.sample.yml to see the documentation for currently available configuration options.

## Problems? Questions?

If you have trouble upgrading, please contact us on the [support mailing list][mailing-list].

[ce-installer]: http://getgitorious.com/installer
[mailing-list]: https://groups.google.com/forum/#!forum/gitorious
