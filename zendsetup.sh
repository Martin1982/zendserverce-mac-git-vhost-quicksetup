#!/bin/bash
# Quickly setup a repo checkout on the Zend Server CE instance

# read projname
echo "Enter the short name for the project (no spaces allowed):"
read projname

# validate projname
pattern=" |'"
if [[ -z $projname || $projname =~ $pattern ]]
then
  echo "This name has troubles my friend"
  exit 2
fi

# Check if directory exists
if [ -d "/usr/local/zend/apache2/htdocs/$projname" ]
then
    echo "A directory for $projname already exists in /usr/local/zend/apache2/htdocs/"
    exit 2
fi

# read repo string
echo "Enter the checkout-string for the repository:"
read repo

# validate repo not empty
if [[ -z $repo ]]
then
  echo "No repo entered..."
  exit 2
fi

hostnameresult=sudo cat /etc/hosts | grep "$projname.local"

if [[ -z $hostnameresult ]]
then
  echo "Adding new hosts entry"
  echo "127.0.0.1   $projname.local" |  sudo tee -a /etc/hosts
fi

git clone $repo /usr/local/zend/apache2/htdocs/$projname

# output vhost data to /usr/local/zend/etc/sites.d/vhost_<projname>.conf
echo "<VirtualHost *:80>" | sudo tee -a /usr/local/zend/etc/sites.d/vhost_$projname.conf
echo "  ServerName $projname.local" | sudo tee -a /usr/local/zend/etc/sites.d/vhost_$projname.conf
echo "  DocumentRoot /usr/local/zend/apache2/htdocs/$projname" | sudo tee -a /usr/local/zend/etc/sites.d/vhost_$projname.conf
echo "</VirtualHost>" | sudo tee -a /usr/local/zend/etc/sites.d/vhost_$projname.conf

echo "-- Restarting Apache"
sudo /usr/local/zend/bin/zendctl.sh restart-apache
echo "If no errors occured you can now visit http://$projname.local"
