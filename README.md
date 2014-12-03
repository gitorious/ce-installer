# Gitorious Community Edition Installer

The Gitorious Community Edition installer is created and maintained by
[Gitorious AS](http://gitorious.com) under the GPL3 license. It is offered
without warranty. If you run into issues, consider seeking help in the
[Gitorious Google Group](http://groups.google.com/group/gitorious?hl=en).  For
professional, long-term support, please consider **Gitorious Enterprise
Edition** (available as [Local Install](http://gitorious.com/local_install) or
[Managed Server](http://gitorious.com/managed_server).

## Video walkthrough

Here's a brief [video walkthrough](https://vimeo.com/49337989). Note that it's
best viewed in fullscreen. The video will refer to the steps outlined in this
document - keep reading below to find detailed written instructions.

## Introduction and assumptions

Welcome to the official Gitorious Community Edition Installer. By following
this guide you'll set up your own instance of Gitorious within half an hour
(depending on your bandwidth).

You will end up with a basic Gitorious installation running on port 80 using
sane, default settings, running in private mode with unlimited private repos
enabled. The only option you will be prompted for during the installation is
the intended hostname of your Gitorious server.

You will be running on v3.0.0 of [[http://gitorious.org/gitorious/mainline][the
Gitorious master branch]], and you can manually reconfigure the server however
you want once the initial install has completed.

We assume the following:

1. You are installing on a CentOS 6.* server /(Debian/Ubuntu support coming soon)/
2. You have full superuser/root access on the server
3. Your server has at least 2-4 GB free memory
4. Your server has at least 1 GB free harddrive space (plus however
   much space you need for hosting git repositories)
5. Gitorious isn't sharing the server with other webapps, and is the
   sole subscriber to the underlying message queues and services
6. You are fine with the installer installing packages and modifying
   some server config along the way (including the iptables).

Everything cool? Ok, let's go!

## Installation procedure

For the following steps, please make sure you are logged in as superuser/root.

### Prepare

First, we're going to need `git` to clone the installer into your
server. Let's install it (if it's not already present):

    yum install git

Then, clone the installer to the server, and move into the `ce-installer` dir:

    git clone https://git.gitorious.org/gitorious/ce-installer.git && cd ce-installer

### Install

Now, start the installation:

    ./install.sh

The installer will ask you for your desired hostname, ie.  the
URL where developers expect to find your Gitorious installation.

    Determining hostname for Gitorious installation...
    What hostname should this Gitorious instance run under?
    (Hit enter for current hostname 'localhost.localdomain'):

Set your intended hostname, or just hit enter to accept the server's
current hostname (don't worry, you can easily change it later on).

*Note: hostname needs to be a valid hostname, meaning it will need to have at least one period (.) in its name. In other words, 'gitorioustest' is invalid, but 'gitorioustest.localdomain' is valid.*

The installer will now install Gitorious with all dependencies. How
long this takes varies a bit, depending on your bandwidth, as the
installer will download and install packages amounting to roughly 1
GB. On a decent rig with 25Mbit+ bandwidth, this takes at least 10-15
minutes.

When the installer finishes, it should look something like this:

    Database created.
    --------------------
    Your installation of Gitorious Community Edition is complete.
    This installer is created and maintained by Gitorious AS under the GPL3 license.
    For professional, long-term support, please consider Gitorious Enterprise Edition.
    http://gitorious.com
    --------------------
    Done. Please reboot the server.

Restart the server to make everything take effect (and to confirm
that your Gitorious instance will come back up again every time your
server reboots).

    reboot

### Try it out

Your Gitorious installation should now be ready to roll.

You'll need a user to log into the Gitorious web frontend. Let's
create an admin user.

    cd /var/www/gitorious/app && bin/create-user

You'll be prompted for a login email and
password:

    Enter e-mail:
    thomas@kjeldahlnilsson.net
    Enter login (thomas):
    Enter password: *************
    Make user admin? (y/n) y
    User 'thomas' created successfully.

Now let's test your Gitorious installation:

1. Browse to the hostname url you chose during installation.
   *Note that you'll need to access it using the same hostname as the one set during the installation. In other words, if the hostname is 'gitorioustest.localdomain', you can't use the raw ip address because the login will fail due to Gitorious/Rails's authenticity validation.*
   If you cannot reach the server by that hostname through DNS, then update your local /etc/hosts file correspondingly.
2. Log in using the admin user you created in the last paragraph.
3. Create a new project and repo (note: you'll be asked to enter your
   public ssh key before you can create your own project).
4. Push, pull and clone your new git repo.

Did everything work? *Congratulations, you're up and running with Gitorious!*

## FAQ

### I get a "Sorry, something went wrong" message when I try to log in - what's up?

You are most likely using an unexpected hostname when logging in. You
have to access your Gitorious server using the same hostname as you
set during the installation, or the login will fail. This is due to an
authenticity check that Gitorious performs during user login: the url
that users access it with must match its configured hostname. If the
server hostname isn't DNSed on the internet yet (or if your server is
only for internal use) you'll have to update your /etc/hosts file to
map the server's ip to the hostname you chose during the Gitorious
installation.

### Can I reconfigure my Gitorious installation?

You certainly can. The main settings are located in
`/var/www/gitorious/app/config/gitorious.yml`. There's also a sample
settings file, `gitorious.sample.yml`, which contains examples and
documentation of all the available options.

Note that changing settings usually requires a subsequent restart of
Gitorious before they take effect. Restart by running the
`restart_unicorn` command:

    cd /var/www/gitorious/app && RAILS_ENV=production script/restart_unicorn

### How do I add users?

Unless your installation is running in public mode, users cannot
simply register from the web front-page: you'll have to add new users
yourself in the backend.  Run the `bin/create-user` command to create a
new user:

    cd /var/www/gitorious/app && RAILS_ENV=production ruby bin/create-user

If you want the new user to be a site admin, either create the users
with the `bin/create-user` command instead, or toggle site admin status on the
user at `http://<HOSTNAME>/admin/users`.

### Where and how is my data stored?

Gitorious stores its hosted data in two locations: git repositories
which go directly onto the filesystem, and the data of the Gitorious
webapp, which goes into MySQL. You'll find the git repositories in
`/var/www/gitorious/repositories`. You can extract your data from
MySQL by running `mysqldump` on the `gitorious_production` database.
However, in practice it's easier to simply pull out your data by
running the `bin/snapshot` script described below, in the backup
FAQ section.

### How do I change the hostname?

Rerun `change_hostname.sh` from your `ce-installer` directory. This
will perform the same interactive configuration of Gitorious and
server hostname as you did during the inital installation.

    cd ~/ce-installer/ && ./change_hostname.sh

Then restart Gitorious:

    cd /var/www/gitorious/app && RAILS_ENV=production script/restart

### How do I fix "untrusted certificate" warnings?

The stock installation of Gitorious CE doesn't include preinstalled
SSL certificates for your hostname. Gitorius is running under Apache,
so to fix this you'll have to [[http://httpd.apache.org/docs/2.2/ssl/ssl_faq.html#selfcert][install an SSL certificate]] for the
domain/hostname your Gitorious installation is running at.

Note: If it's not a showstopper for you, then simply add an exception
for the domain in your browser. You'll still be able to use the
Gitorious installation, but new users will have to click past those
SSL cert warnings when they initially visit the site.

### How do I back it up?

Run `/var/www/gitorious/app/bin/snapshot` as superuser/root.

    cd /var/www/gitorious/app/ && bin/snapshot ./testsnapshot.tar

This will back up the current state of your Gitorious site (including
your hosted git repositories) in a single tarball. You can restore the
data from the same tarball (see the next FAQ section).

So just set up a cronjob to do regular snapshots and offsite transfers
of said backups.

### How do I perform disaster recovery?

Given a tarball created by the aforementioned
`/var/www/gitorious/app/bin/snapshot` script, you'll be able to
restore the state of the Gitorious site (and the hosted git repos)
from the same tarball by running `bin/restore`:

    cd /var/www/gitorious/app/ && bin/restore ./testsnapshot.tar

### How do I make my hosted git repositories available for anonymous users?

The default private mode will not allow anonymous access to content or
user registration. Only logged in users which you have created
explictly can surf your Gitorious installation. But when Gitorious is
running in public mode, anyone can view and clone repositories in your
Gitorious site, without logging in.

Note that this will also allow anyone to register user accounts in
your Gitorious site.

To change to public mode, edit
`/var/www/gitorious/app/config/gitorious.yml`. Set `public_mode:
true`. Then restart with `script/restart` for it to take effect.

### What's the recommended specs for a Gitorious server?

At least 2-4GB RAM initially, since Gitorious can be a bit of a memory
hog. The resource usage will go up linearly with increasing numbers of
users, web traffic and git operations on your installation.

### How do I upgrade my Gitorious instance?

This will update Gitorious to latest stable version. Works with 
Gitorious releases since 2.4.x:

    cd ~/ce-installer && ./upgrade.sh

If you have an older Gitorious instance, please refer [to this guide](https://gitorious.org/gitorious/pages/Upgrading).

### How do I install Gitorious on other operating systems?

Community installer supports only CentOS. However you can use any 
other operating system with the [Virtual Appliance](http://getgitorious.com/virtual-appliance).