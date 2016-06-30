#!/bin/bash

echo '         
   ##### ##   ## ###### #######   
  ###### ##   ## ##     ##              
  ##     ##   ## ##     ##                 
  ##     ####### ###### #######
  ##     ##   ## ##     ##
  ###### ##   ## ##     ##
   ##### ##   ## ###### ##
'

usage() {
  echo '
   Usage: 
      ./chef-installer.sh -i <INSTALLER_URL>
   
   Note: Installer must be compatible for x86_64 architecture.
  '
}

while getopts "i:" opt; do
  case ${opt} in
    i)
      export INSTALLER_URL=${OPTARG}
      ;;
    *)
      echo "Invalid installer url passed."
      usage
      ;;
  esac
done

if [ $# -eq 0 ]; then
  echo "No Installer URL is provided."
  echo "Using default installer."
fi 


# Determine OS platform
UNAME=$(uname | tr "[:upper:]" "[:lower:]")
# If Linux, try to determine specific distribution
if [ "$UNAME" == "linux" ]; then
    # If available, use LSB to identify distribution
    if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
        export DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
    # Otherwise, use release info file
    elif [ -f /etc/issue ]; then
        export DISTRO=$(sed -n 1p /etc/issue | cut -d ' ' -f1 )
    else
        export DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)
    fi
fi
# For everything else (or if above failed), just use generic identifier
#[ "$DISTRO" == "" ] && export DISTRO=$UNAME
#unset UNAME

case ${DISTRO} in
 "Ubuntu")
   if [ $# -eq 0 ]; then
     echo "Default Installer: chef-server-core_12.7.0-1_amd64.deb"
     export INSTALLER_URL=https://packages.chef.io/stable/ubuntu/14.04/chef-server-core_12.7.0-1_amd64.deb
   fi
   export INSTALLER_NAME=$(echo ${INSTALLER_URL} | rev | cut -d'/' -f1 | rev)
   apt-get update \
    && apt-get install -y \
      curl \
      git \
      make \
      dpkg \
      vim \
      wget
   wget $INSTALLER_URL
   dpkg -i ${INSTALLER_NAME}
   echo "Reconfiguring Chef Server."
   chef-server-ctl reconfigure

   echo "Customizing chef-server.rb"
   if [ -f /etc/opscode/chef-server.rb ]; then
     rm -f /etc/opscode/chef-server.rb
     cp -av ./chef-server.rb /etc/opscode/
   fi

   chef-server-ctl reconfigure

   echo "Creating Default User and Group"
   chef-server-ctl user-create admin JOHN SMITH johnsmith@adop.io 'Password01' --filename admin.pem
   chef-server-ctl org-create devops 'Accenture' --association_user admin --filename admin-validator.pem

   echo "Installing Management Console"
   chef-server-ctl install chef-manage
   chef-server-ctl reconfigure
   chef-manage-ctl reconfigure --accept-license

   echo "Checking Status of Management Console"
   chef-manage-ctl status

   echo "Testing Management Console APIs"
   chef-manage-ctl test

   echo "Installing Opscode Reporting"
   chef-server-ctl install opscode-reporting
   chef-server-ctl reconfigure
   opscode-reporting-ctl reconfigure --accept-license

   ;;
esac
