#!/bin/bash

if [ "$1" == "ati" ];
then
	VIDEO_DRIVER="fgrlx"
	VIDEO_MANUFACTURER="ATI"
elif [ "$1" == "nvidia" ];
then
	VIDEO_DRIVER="nvidia-current"
	VIDEO_MANUFACTURER="NVIDIA"
elif [ "$1" == "intel" ];
then
	VIDEO_DRIVER="i965-va-driver"
	VIDEO_MANUFACTURER="INTEL"
else
	echo ""
	echo "$(tput setaf 1)$(tput bold)ERROR: Please provide the video card manufaturer parameter (ati / nvidia / intel)$(tput sgr0)"
	echo ""
	exit
fi

HOME_DIRECTORY="/home/xbmc/"
TEMP_DIRECTORY=$HOME_DIRECTORY"temp/"
SOURCES_FILE="/etc/apt/sources.list"
SOURCES_BACKUP_FILE="/etc/apt/sources.list.bak"
ENVIRONMENT_FILE="/etc/environment" 
ENVIRONMENT_BACKUP_FILE="/etc/environment.bak"
INIT_FILE="/etc/init.d/xbmc"
XBMC_ADDONS_DIR="/home/xbmc/.xbmc/addons/"
XWRAPPER_BACKUP_FILE="/etc/X11/Xwrapper.config.bak"
XWRAPPER_FILE="/etc/X11/Xwrapper.config"

echo ""
echo ""
echo "$(tput setaf 2)$(tput bold)Please enter your password to start Ubuntu preparation and XBMC installation and be pation while the installation is in progress.$(tput sgr0)"
echo "$(tput setaf 2)$(tput bold)The installation of some packages may take a while depending on your internet connection speed.$(tput sgr0)"
echo ""

if [ -f $ENVIRONMENT_BACKUP_FILE ];
then
	sudo rm $ENVIRONMENT_FILE > /dev/null
	sudo cp $ENVIRONMENT_BACKUP_FILE $ENVIRONMENT_FILE > /dev/null
else
	sudo cp $ENVIRONMENT_FILE $ENVIRONMENT_BACKUP_FILE > /dev/null
fi

sudo sh -c 'echo "LC_MESSAGES=\"C\"" >> /etc/environment'
sudo sh -c 'echo "LC_ALL=\"en_US.UTF-8\"" >> /etc/environment'

echo ""
echo "$(tput setaf 2)$(tput bold)* Locale environment bug successfully fixed$(tput sgr0)"
echo ""
echo "$(tput setaf 3)$(tput bold)Adding Wsnipex xbmc-xvba-testing PPA...$(tput sgr0)"

if [ -f $SOURCES_BACKUP_FILE ];
then
	sudo rm $SOURCES_FILE > /dev/null
	sudo cp $SOURCES_BACKUP_FILE $SOURCES_FILE > /dev/null
else
	sudo cp $SOURCES_FILE $SOURCES_BACKUP_FILE > /dev/null
fi

sudo sh -c 'echo "deb http://ppa.launchpad.net/wsnipex/xbmc-xvba-testing/ubuntu quantal main" >> /etc/apt/sources.list' > /dev/null
sudo sh -c 'echo "deb-src http://ppa.launchpad.net/wsnipex/xbmc-xvba-testing/ubuntu quantal main" >> /etc/apt/sources.list' > /dev/null

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A93CABBC > /dev/null 2>&1
sudo apt-get update > /dev/null
sudo apt-get -y dist-upgrade > /dev/null

echo "$(tput setaf 2)$(tput bold)* Wsnipex xbmc-xvba-testing PPA successfully added$(tput sgr0)"
echo ""
echo "$(tput setaf 3)$(tput bold)Installing xinit...$(tput sgr0)"

sudo apt-get -y install xinit > /dev/null

echo "$(tput setaf 2)$(tput bold)* Xinit successfully installed$(tput sgr0)"
echo ""
echo "$(tput setaf 3)$(tput bold)Installing power management packages...$(tput sgr0)"

sudo apt-get -y install upower acpi-support > /dev/null

echo "$(tput setaf 2)$(tput bold)* Power management packages successfully installed$(tput sgr0)"
echo ""
echo "$(tput setaf 3)$(tput bold)Installing audio packages.$(tput sgr0)"
echo "$(tput setaf 6)$(tput bold)!! Please ensure no channels are muted that shouldn't be and that the volumes are up...$(tput sgr0)"

sudo usermod -a -G audio xbmc > /dev/null
sudo apt-get -y install linux-sound-base alsa-base alsa-utils pulseaudio libasound2 upower acpi-support > /dev/null
sudo alsamixer

echo "$(tput setaf 2)$(tput bold)* Audio packages successfully installed$(tput sgr0)"
echo ""

read -p "$(tput setaf 3)$(tput bold)Do you want to install and configure IR remote support (Y/n)? $(tput sgr0) " -n 1
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo apt-get -y install lirc > /dev/null
    echo ""
    echo "$(tput setaf 2)$(tput bold)* Lirc successfully installed$(tput sgr0)"
else
	echo ""
	echo "$(tput setaf 6)$(tput bold)* Lirc installation skipped$(tput sgr0)"
fi

echo ""
echo "$(tput setaf 3)$(tput bold)Installing XBMC...$(tput sgr0)"

sudo apt-get -y install xbmc > /dev/null

echo "$(tput setaf 2)$(tput bold)* XBMC successfully installed$(tput sgr0)"
echo ""
echo "$(tput setaf 3)$(tput bold)Downloading and installing Addon repositories installer plugin...$(tput sgr0)"

mkdir -p $TEMP_DIRECTORY > /dev/null
cd $TEMP_DIRECTORY > /dev/null
wget -q https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/addons/plugin.program.repo.installer-1.0.5.tar.gz

if [ ! -d $XBMC_ADDONS_DIR ];
then
	mkdir -p $XBMC_ADDONS_DIR > /dev/null
fi

tar -xvzf ./plugin.program.repo.installer-1.0.5.tar.gz -C $XBMC_ADDONS_DIR > /dev/null 2>&1

echo "$(tput setaf 2)$(tput bold)* Addon repositories installer plugin successfully installed$(tput sgr0)"
echo ""
echo "$(tput setaf 3)$(tput bold)Installing $VIDEO_MANUFACTURER video drivers...$(tput sgr0)"

if [ $1 == "ati" ];
then
	wget -q https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/12.04/install_ati_driver.sh
	bash install_ati_driver.sh xbmc > /dev/null
else
	sudo apt-get -y install $VIDEO_DRIVER > /dev/null
fi

echo "$(tput setaf 2)$(tput bold)* $VIDEO_MANUFACTURER video drivers successfully installed$(tput sgr0)"
echo ""
echo "$(tput setaf 3)$(tput bold)Downloading and applying xbmc init.d script$(tput sgr0)"

wget -q https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/12.04/xbmc_init_script > /dev/null

if [ -f $INIT_FILE ];
then
	sudo rm $INIT_FILE > /dev/null
fi

sudo mv ./xbmc_init_script $INIT_FILE > /dev/null
sudo chmod a+x /etc/init.d/xbmc > /dev/null
sudo update-rc.d xbmc defaults > /dev/null

echo "$(tput setaf 2)$(tput bold)* init.d script succesfully downloaded and applied$(tput sgr0)"
echo ""
echo "$(tput setaf 3)$(tput bold)Installing XBMC boot screen...$(tput sgr0)"

sudo apt-get -y install plymouth-label v86d > /dev/null
cd $TEMP_DIRECTORY
wget -q https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/12.04/plymouth-theme-xbmc-logo.deb
sudo dpkg -i plymouth-theme-xbmc-logo.deb > /dev/null

if [ -f /etc/initramfs-tools/conf.d/splash ];
then
	sudo rm /etc/initramfs-tools/conf.d/splash > /dev/null
fi

sudo touch /etc/initramfs-tools/conf.d/splash > /dev/null
sudo sh -c 'echo "FRAMEBUFFER=y" >> /etc/initramfs-tools/conf.d/splash' > /dev/null
sudo update-grub > /dev/null 2>&1
sudo update-initramfs -u > /dev/null 2>&1

echo "$(tput setaf 2)$(tput bold)* XBMC boot screen successfully installed$(tput sgr0)"
echo ""
echo "$(tput setaf 3)$(tput bold)Reconfiguring X-server...$(tput sgr0)"

if [ ! -f $XWRAPPER_BACKUP_FILE ];
then
	sudo mv $XWRAPPER_FILE $XWRAPPER_BACKUP_FILE > /dev/null
fi

if [ -f $XWRAPPER_FILE ];
then
	sudo rm $XWRAPPER_FILE > /dev/null
fi

sudo touch $XWRAPPER_FILE > /dev/null
sudo sh -c 'echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config'
#sudo dpkg-reconfigure x11-common

echo "$(tput setaf 2)$(tput bold)* X-server successfully reconfigured$(tput sgr0)"
echo ""
echo "$(tput setaf 6)$(tput bold)Cleaning up...$(tput sgr0)"

sudo apt-get -y autoclean > /dev/null
sudo apt-get -y autoremove > /dev/null
sudo rm -r $TEMP_DIRECTORY > /dev/null
rm $HOME_DIRECTORY$0

echo "$(tput setaf 6)$(tput bold)Rebooting system...$(tput sgr0)"
echo ""

sudo reboot now > /dev/null
