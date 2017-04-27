#!/bin/bash
####################################################################################################################
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'
gitdir=$PWD

##Logging setup
logfile=/var/log/antivmdetect_install.log
mkfifo ${logfile}.pipe
tee < ${logfile}.pipe $logfile &
exec &> ${logfile}.pipe
rm ${logfile}.pipe

##Functions
function print_status ()
{
    echo -e "\x1B[01;34m[*]\x1B[0m $1"
}

function print_good ()
{
    echo -e "\x1B[01;32m[*]\x1B[0m $1"
}

function print_error ()
{
    echo -e "\x1B[01;31m[*]\x1B[0m $1"
}

function print_notification ()
{
	echo -e "\x1B[01;33m[*]\x1B[0m $1"
}

function error_check
{

if [ $? -eq 0 ]; then
	print_good "$1 successfully."
else
	print_error "$1 failed. Please check $logfile for more details."
exit 1
fi

}

function install_packages()
{
print_status "${YELLOW}Installing needed packages${NC}"
apt-get update &>> $logfile && apt-get install -y --allow-unauthenticated ${@} &>> $logfile
error_check 'Package installation completed'

}

function dir_check()
{

if [ ! -d $1 ]; then
	print_notification "$1 does not exist. Creating.."
	mkdir -p $1
else
	print_notification "$1 already exists. (No problem, We'll use it anyhow)"
fi

}

########################################
##BEGIN MAIN SCRIPT##
#Pre checks: These are a couple of basic sanity checks the script does before proceeding.
export DEBIAN_FRONTEND=noninteractive

echo -e "${YELLOW}What is the name of your cuckoo user?${NC}"
read name
##Folder setup
dir_check /usr/bin/cd-drive
dir_check /home/$name/tools
##Dep install
print_status "${YELLOW}Waiting for dpkg process to free up...${NC}"
print_status "${YELLOW}If this takes too long try running ${RED}sudo rm -f /var/lib/dpkg/lock${YELLOW} in another terminal window.${NC}"
while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do
   sleep 1
done
install_packages python-dmidecode re acpidump unzip mesa-utils
##Antivm install
print_status "${YELLOW}Installing antivmdetect and tools${NC}"
mv DSDT-Intel-BOXDP55KG.aml /home/$name/tools/DSDT-Intel-BOXDP55KG.bin
cd /home/$name/tools
git clone https://github.com/nsmfoo/antivmdetection.git  &>> $logfile
mv antivmdetection antivmdetection_32-bit
cp -r antivmdetection_32-bit/ /home/$name/tools/antivmdetection_64-bit
wget https://download.sysinternals.com/files/VolumeId.zip  &>> $logfile
wget http://www.afterdawn.com/software/general/download.cfm/devmanview_32-bit?mirror_id=0&version_id=88412&software_id=4019  &>> $logfile
wget http://www.afterdawn.com/software/general/download.cfm/devmanview_64-bit?mirror_id=0&version_id=88411&software_id=4018  &>> $logfile
sleep 10
unzip VolumeId  &>> $logfile
#32-bit
cd /home/$name/tools/antivmdetection_32-bit
cp /home/$name/tools/DSDT-Intel-BOXDP55KG.bin $PWD
mv /home/$name/tools/Volumeid.exe /home/$name/tools/antivmdetection_32-bit/
mv /home/$name/tools/devmanview_32* /home/$name/tools/antivmdetection_32-bit/DevManView.exe
touch computer.lst
touch user.lst
#64-bit
cd /home/$name/tools/antivmdetection_64-bit
mv /home/$name/tools/DSDT-Intel-BOXDP55KG.bin $PWD
mv /home/$name/tools/Volumeid64.exe /home/$name/tools/antivmdetection_64-bit/
mv /home/$name/tools/devmanview_64* /home/$name/tools/antivmdetection_64-bit/DevManView.exe
touch computer.lst
touch user.lst
##File permissions
chown $name:$name -R /home/$name/tools/
error_check 'Antivm tools installed'


