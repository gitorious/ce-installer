#!/bin/bash
source config.sh

if [ "`cat modules/gitorious/manifests/database.pp | grep DB_PASSWORD`" ]; then
    echo "Randomizing db password in puppet recipe..."
    NEW_PASSWORD=$(dd if=/dev/random bs=1 count=4 2>/dev/null | sha256sum | head -c 40)
    sed -i "s/DB_PASSWORD/$NEW_PASSWORD/" modules/gitorious/manifests/database.pp
    sed -i "s/DB_PASSWORD/$NEW_PASSWORD/" modules/gitorious/files/config/database.yml
    echo "Db password updated."
fi

echo "Applying Puppet recipe (will take a while, please be patient)..."
ruby apply_puppet_recipe.rb
PUPPETRESULT=$?
[ $PUPPETRESULT -ne 0 ] && echo "Installation failed." && exit
echo "Puppet recipe applied successfully."

echo "Creating the database..."
cd /var/www/gitorious/app && bin/rake db:drop db:create db:migrate VERBOSE=false
echo "Database created."

echo "Building Thinking Sphinx index..."
cd /var/www/gitorious/app && bin/rake ts:rebuild VERBOSE=false
echo "Index created."

echo "Randomizing cookie_secret..."
NEW_TOKEN=$(dd if=/dev/random bs=1 count=4 2>/dev/null | sha256sum | head -c 40)
sed -i "s/cookie_secret:.*/cookie_secret: $NEW_TOKEN/" /var/www/gitorious/app/config/gitorious.yml
echo "Rails cookie randomized."

echo "Creating admin user..."
cd /var/www/gitorious/app && VERBOSE=false bin/create-user "admin@$(hostname)" "admin" "gitorious" "y"
echo "Admin user created."
echo "  login: admin, password: gitorious"
echo "Please change admin user password on first login."

echo "Restarting services"
restart_gitorious

# Anonymous pingback on install
curl -s http://getgitorious.com/installer_completed > /dev/null

echo "--------------------"
echo "Your installation of Gitorious Community Edition is complete."
echo "This installer is created and supported by Gitorious AS."
echo "For professional, long-term support, please consider Gitorious Enterprise Edition."
echo "http://gitorious.com"
echo "--------------------"

echo "Done. Please reboot the server."
