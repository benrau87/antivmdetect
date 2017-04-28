#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi
echo -e "${YELLOW}What VM would you like to create antivm scripts for?${NC}"
read name
mkdir $name/
cp DSDT-Intel* $name/DSDT-Intel*
mv eample $name/virtualboxsetup.sh
chmod +x virtualboxsetup.sh
#!/bin/bash

RANGE=255
number=$RANDOM
numbera=$RANDOM
numberb=$RANDOM
let "number %= $RANGE"
let "numbera %= $RANGE"
let "numberb %= $RANGE"
octets='00-19-eC'
octeta=`echo "obase=16;$number" | bc`
octetb=`echo "obase=16;$numbera" | bc`
octetc=`echo "obase=16;$numberb" | bc`
macadd="${octets}-${octeta}-${octetb}-${octetc}"

cd $name/
sed -i 's/"$1"/'"$name"'/g' virtualboxsetup.sh
sed -i 's/"$1"/'"$name"'/g' virtualboxsetup.sh

