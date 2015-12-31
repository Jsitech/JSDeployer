#!/bin/bash
# SecureWPDeployer - Automated Secure Joomla Deployer
#Jason Soto
#jason_soto [AT] jsitech [DOT] com
#www.jsitech.com
#Twitter = @JsiTech

# Server Hardening With JShielder
# Joomla Hardening With WPHardening From Daniel Maldonado @elcodigok


# @license          http://www.gnu.org/licenses/gpl.txt  GNU GPL 3.0
# @author           Jason Soto <jason_soto@jsitech.com>
# @link             http://www.jsitech.com


##############################################################################################################

f_banner(){
echo
echo "
     _ ____  ____             _
    | / ___||  _ \  ___ _ __ | | ___  _   _  ___ _ __
 _  | \___ \| | | |/ _ \ '_ \| |/ _ \| | | |/ _ \ '__|
| |_| |___) | |_| |  __/ |_) | | (_) | |_| |  __/ |
 \___/|____/|____/ \___| .__/|_|\___/ \__, |\___|_|
                       |_|            |___/

Joomla Secure Deployer
By Jason Soto "
echo
echo
}

################################################################################################################

spinner ()
{
    bar=" ++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    barlength=${#bar}
    i=0
    while ((i < 100)); do
        n=$((i*barlength / 100))
        printf "\e[00;34m\r[%-${barlength}s]\e[00m" "${bar:0:n}"
        ((i += RANDOM%5+2))
        sleep 0.02
    done
}

####################################################################################################################
#Check if running with root User

if [ "$USER" != "root" ]; then
      echo "Permission Denied"
      echo "Can only be run by root"
      exit
else
      clear
      f_banner
      echo -e "\e[34m########################################################################\e[00m"
      echo ""
      echo -e "     *** Welcome to the Automated Secure Joomla Deployer***"
      echo -e "     Server Hardening with JShielder <www.jsitech.com/jshielder"
      echo ""
      echo -e "\e[34m########################################################################\e[00m"
      echo "  "
      sleep 10
fi

# Checking Distro Version
clear
f_banner
echo ""
sleep 2
echo -e "\e[34m--------------------------------------------------------------------------------------------\e[00m"
echo -e "\e[93m[?]\e[00m Checking what Distro you are Running"
echo -e "\e[34m--------------------------------------------------------------------------------------------\e[00m"
echo ""
distro=$(cat /etc/*-release |grep "DISTRIB_CODENAME" | cut -d '=' -f2)
spinner
echo ""
echo -e "\e[34m----------------------------------------------------------------------------------------------\e[00m"
echo ""
echo -ne "\e[93m>\e[00m "

# Selecting JSHielder for the detected Distro
if [ "$distro" = "trusty" ]; then
    apt-get install git
    apt-get install python-git
    git clone https://github.com/Jsitech/JShielder
    cd JShielder/UbuntuServer_14.04LTS/
    chmod +x jshielder.sh
    ./jshielder.sh

elif [ "$distro" = "vivid" ]; then
    apt-get install git
    apt-get install python-git
    git clone https://github.com/Jsitech/JShielder
    cd JShielder/UbuntuServer_15.04/
    chmod +x jshielder.sh
    ./jshielder.sh

# If no Compatible Distro is Detected

else
    clear;
    echo "No compatible Distro Detected... Exiting"
    sleep 5
    exit
fi

#Proceed with Joomla Installation

clear
f_banner
echo ""
echo -e "\e[34m--------------------------------------------------------------------\e[00m"
echo -e "\e[93m[-]\e[00m We Will now Proceed with the Joomla CMS Installation "
echo -e "\e[34m--------------------------------------------------------------------\e[00m"
echo ""

#Check Distro Package Manager and Disabling ModSecurity and ModEvasive for Proper Configuration

ls /usr/bin/dpkg > /dev/null 2>&1
if [ $? -eq 0 ]; then
    PKG=apt-get
    sed -i s/SecRuleEngine\ On/SecRuleEngine\ DetectionOnly/g /etc/modsecurity/modsecurity.conf
    a2dismod evasive
    service apache2 reload
else
    PKG=yum
    sed -i s/SecRuleEngine\ On/SecRuleEngine\ DetectionOnly/g /etc/httpd/conf.d/mod_security.conf
    service httpd reload
fi



#Install Joomla CMS
    clear
    f_banner
    echo ""
    echo -e "\e[93m[-]\e[00m Name the Directory that will hold the Joomla installation"
    echo ""
    echo -e "\e[34m--------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[?]\e[00m Please type a name for the Directory : "
    echo -e "\e[34m--------------------------------------------------------------------\e[00m"
    echo ""
    echo -ne "\e[93m>\e[00m "
    read DIR
    echo ""
    echo ""
    $PKG install unzip
    wget https://github.com/joomla/joomla-cms/releases/download/3.4.8/Joomla_3.4.8-Stable-Full_Package.zip
    mkdir /var/www/html/$DIR
    unzip Joomla_3.4.8-Stable-Full_Package.zip -d /var/www/html/$DIR
    touch /var/www/html/$DIR/configuration.php
    chmod 777 /var/www/html/$DIR/configuration.php


#Create Joomla Database
clear
f_banner
echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
echo -e "\e[93m[?]\e[00m Going to Create the Joomla Database"
echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
echo ""
echo " *** MEMORIZE THE INFO YOU WILL TYPE HERE, WILL NEED IT LATER ***"
echo -n " Type Database Name: "; read db_name
echo -n " Type User:  "; read db_user
echo -n " Type Password:  "; read db_pass
cd ../..
chmod +x JoomDBCreate.sh
./JoomDBCreate.sh $db_name $db_user $db_pass
echo ""
echo ""


# Complete Joomla Installation via the Browser
clear
f_banner
echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
echo -e "\e[93m[?]\e[00m We will now Complete the Joomla Install in the Browser Before Proceeding"
echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
IP=$(ip route get 1 | awk '{print $NF;exit}')
echo ""
echo "   Access your Installer in The Browser to Complete Installation

         http://$IP/$DIR

         http://<Your_Domain>/$DIR


         DO NOT PROCEED TO NEXT STEP UNTIL DONE "
read -p "Press any key to continue... "

rm -rf /var/www/html/$DIR/installation/
chmod 444 /var/www/html/$DIR/configuration.php


# Proceeding with Installation Hardening
clear
f_banner
echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
echo -e "\e[93m[?]\e[00m We Will now Hardened the Joomla Installation"
echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
echo ""
spinner
sleep 0.02
ls /usr/bin/dpkg > /dev/null 2>&1
if [ $? -eq 0 ]; then
    chown -R www-data:www-data /var/www/html/$DIR/
    sed -i s/SecRuleEngine\ DetectionOnly/SecRuleEngine\ On/g /etc/modsecurity/modsecurity.conf
    a2enmod evasive
    service apache2 reload
else
   rm -f /etc/httpd/conf.d/welcome.conf
   chown -R apache:apache /var/www/html/$DIR/
   sed -i s/SecRuleEngine\ DetectionOnly/SecRuleEngine\ On/g /etc/httpd/conf.d/mod_security.conf
   service httpd reload
fi

clear
f_banner
echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
echo -e "\e[93m[?]\e[00m Setting Secure .htaccess file and Setting Proper Permissions"
echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
echo ""
spinner
sleep 0.02
cp templates/htaccess.txt /var/www/html/$DIR/.htaccess

ls /usr/bin/dpkg > /dev/null 2>&1
if [ $? -eq 0 ]; then
    chown www-data:www-data /var/www/html/$DIR.htaccess
    cp templates/apache /etc/apache2/apache2.conf
else
    chown apache:apache /var/www/html/$DIR.htaccess
fi

cd /var/www/html/$DIR
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;

#Create index to protect from directory Browsing

clear
f_banner
echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
echo -e "\e[93m[?]\e[00m Creating Blank index.php on Folders to Prevent Directory Browsing"
echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
echo ""
spinner
sleep 0.02

touch bin/index.php \
cache/index.php \
cli/index.php \
components/index.php \
images/index.php \
includes/index.php \
language/index.php \
layouts/index.php \
libraries/index.php \
logs/index.php \
media/index.php \
modules/index.php \
plugins/index.php \
templates/index.php \
tmp/index.php


clear
f_banner
echo ""
sleep 2
echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
echo -e "\e[93m[?]\e[00m Deployment finished, Will reboot Server"
echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
echo -e "\e[93m[?]\e[00m After Restarting you can access your Server Remotely via port 372 for Debian Based or 2020 for Red Hat Based Distros"
echo ""
sleep 10
reboot
