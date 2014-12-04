# Gitorious Community Edition Installer

The Gitorious Community Edition installer is created and maintained by
[Gitorious AS](http://gitorious.com) under the GPL3 license. It is offered
without warranty. If you run into issues, consider seeking help in the
[Gitorious Google Group](http://groups.google.com/group/gitorious?hl=en).  For
professional, long-term support, please consider **Gitorious Enterprise
Edition** (available as [Local Install](http://gitorious.com/local_install) or
[Managed Server](http://gitorious.com/managed_server)).

## Video walkthrough

Here's a brief [video walkthrough](https://vimeo.com/49337989). Note that it's
best viewed in fullscreen. The video will refer to the steps outlined in this
document - keep reading below to find detailed written instructions.

Note that the video may be slightly out of date with the content presented in
this README.

## Introduction and assumptions

Welcome to the official Gitorious Community Edition Installer. By following
this guide you'll set up your own instance of Gitorious within half an hour
(depending on your bandwidth).

You will end up with a basic Gitorious installation running on ports 80 and 443
(https) using sane, default settings, running in private mode with unlimited
private repos enabled. The only option you will be prompted for during the
installation is the hostname (FQDN) by which you want to access your Gitorious
installation.

You will be running on v3.2.0 of [Gitorious web
app](http://gitorious.org/gitorious/mainline), and you can manually reconfigure
the server however you want once the initial install has completed.

We assume the following:

1. You are installing on a CentOS 6 or Ubuntu 14.04 server
2. You have full superuser/root access on the server
3. Your server has at least 2-4 GB free memory
4. Your server has at least 1 GB free harddrive space (plus however
   much space you need for hosting git repositories)
5. Gitorious isn't sharing the server with other webapps, and is the
   sole subscriber to the underlying message queues and services
6. You are fine with the installer installing packages and modifying
   some server config along the way.

Everything cool? Ok, let's go!

## Installation

For the following steps, please make sure you are logged in as superuser/root.

### Prepare

First, we're going to need `git` to clone the installer into your
server. Let's install it (if it's not already present).

On CentOS/RHEL:

    yum install -y git

On Ubuntu:

    apt-get install -y git

Then, clone the installer to the server, and move into the `ce-installer` dir:

    git clone https://gitorious.org/gitorious/ce-installer.git && cd ce-installer

### Install

Now, start the installation:

    ./install.sh

The installer will ask you for your desired hostname, ie.  the
URL where developers expect to find your Gitorious installation.

    +- Welcome to Gitorious installer!
    +- This script will install Gitorious v3.2.0 on this machine.

    Following information will be used to generate configuration file and SSL certificate:
      hostname (FQDN): gitorious.local

Set your intended hostname, or just hit enter to accept the server's
current hostname.

*Note: hostname needs to be a valid hostname, meaning it will need to have at least one period (.) in its name. In other words, 'gitorioustest' is invalid, but 'gitorioustest.localdomain' is valid.*

The installer will now install Gitorious with all dependencies. How
long this takes varies a bit, depending on your bandwidth, as the
installer will download and install packages amounting to roughly 1
GB. On a decent rig with 25Mbit+ bandwidth, this takes at least 10-15
minutes.

When the installer finishes, it should look something like this:

    +- Your installation of Gitorious Community Edition is complete.
    +- Open https://gitorious.local/ in your browser to start.
    +- Log in as admin with "admin" / "g1torious" as credentials.

    +- This script is created and supported by Gitorious AS.
    +- For professional support contact us at sales@gitorious.org
    +- http://gitorious.com

Your Gitorious installation should now be ready to roll.

Now let's test your Gitorious installation:

1. Browse to the hostname url you chose during installation.
   *Note that you'll need to access it using the same hostname as the one set during the installation. In other words, if the hostname is 'gitorioustest.localdomain', you can't use the raw ip address because the login will fail due to Gitorious/Rails's authenticity validation.*
   If you cannot reach the server by that hostname through DNS, then update your local /etc/hosts file correspondingly.
2. Log in using the admin credentials by the installer.
3. Create a new project and repo (note: you'll be asked to enter your
   public ssh key before you can create your own project).
4. Push, pull and clone your new git repo.

Did everything work? *Congratulations, you're up and running with Gitorious!*

## FAQ

### How do I upgrade my Gitorious instance?

See "Upgrading" section below.

### Can I reconfigure my Gitorious installation?

You certainly can. The main settings are located in
`/var/www/gitorious/app/config/gitorious.yml`. There's also a sample settings
file, `gitorious.sample.yml`, which contains examples and documentation of all
the available options.

Note that changing settings usually requires a subsequent restart of Gitorious
before they take effect. Restart with the following command:

    sudo gitoriousctl restart gitorious-web

### How do I add users?

Unless your installation is running in public mode, users cannot simply
register from the web front-page: you'll have to add new users yourself. The
are 2 ways to do this.

One way is to click on "Users" link in Gitorious web app (link visible only to
admins) to access user management page.

Another way is to add a user from the command line on Gitorious server with:

    sudo gitoriousctl exec bin/create-user

### Where and how is my data stored?

Gitorious stores its hosted data in two locations: git repositories which go
directly onto the filesystem, and the data of the Gitorious webapp, which goes
into MySQL. You'll find the git repositories in
`/var/www/gitorious/repositories`. You can extract your data from MySQL by
running `mysqldump` on the `gitorious_production` database.  However, in
practice it's easier to simply pull out your data by running `sudo gitoriousctl
exec bin/snapshot` as described below, in the backup FAQ section.

### How do I change the hostname?

Gitorious doesn't care about the hostname of the machine as reported
by `hostname` command. However, it's very important to access your Gitorious
instance with the same host name as set in Gitorious configuration file (for
authentication cookies to work correctly).

If you want to change the host name by which you access Gitorious edit
`/var/www/gitorious/app/config/gitorious.yml` file, change `host` setting, then
restart the app with:

    sudo gitoriousctl restart gitorious-web

### How do I fix "untrusted certificate" warnings?

The "proper" way is to get a real certificate and put it in `/etc/nginx/ssl`,
replacing self-signed certificate the installer creates.

If it's not a showstopper for you, then simply add an exception for the domain
in your browser. You'll still be able to use the Gitorious installation, but
new users will have to click past those SSL cert warnings when they initially
visit the site.

### How do I back it up?

Run the following command:

    sudo gitoriousctl exec bin/snapshot /full/path/to/snapshot.tar

This will back up the current state of your Gitorious site (including your
hosted git repositories) in a single tarball. You can restore the data from the
same tarball (see the next FAQ section).

So just set up a cronjob to do regular snapshots and offsite transfers of said
backups.

### How do I perform disaster recovery?

Given a tarball created by the aforementioned snapshot command, you'll be able
to restore the state of the Gitorious site (and the hosted git repos) from the
same tarball by running `bin/restore`:

    sudo gitoriousctl exec bin/restore /full/path/to/snapshot.tar

### How do I make my hosted git repositories available for anonymous users?

The default private mode will not allow anonymous access to content or user
registration. Only logged in users which you have created explictly can surf
your Gitorious installation. But when Gitorious is running in public mode,
anyone can view and clone repositories in your Gitorious site, without logging
in.

Note that this will also allow anyone to register user accounts in
your Gitorious site.

To change to public mode, edit `/var/www/gitorious/app/config/gitorious.yml`.
Set `public_mode: true`. Then restart with `sudo gitoriousctl restart
gitorious-web` for it to take effect.

### What's the recommended specs for a Gitorious server?

At least 2-4GB RAM initially, since Gitorious consists of and uses many
services. The resource usage will go up linearly with increasing numbers of
users, web traffic and git operations on your installation.

## Upgrading

To upgrade from Gitorious 2.4.x or 3.x to latest stable release (3.2 as of now), follow these steps:

    git clone https://gitorious.org/gitorious/ce-installer.git && cd ce-installer
    sudo ./upgrade.sh

If you have an older Gitorious instance, please refer [to this guide](https://gitorious.org/gitorious/pages/Upgrading).

To check your current version of Gitorious run:

    grep VERSION /var/www/gitorious/app/lib/gitorious.rb
