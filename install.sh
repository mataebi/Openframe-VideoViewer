#!/bin/bash
#
# Be VERY Careful. This script may be executed with admin privileges.

echo "Installing Openframe Video Viewer..."

if ! [ -z "$TRAVIS" ]; then
    echo "TRAVIS env, don't install"
    exit 0
fi

# Some limited platform detection might be in order... though at present we're targeting the Pi
os=$(uname)
arq=$(uname -m)

if [ $os == "Linux" ]; then

    if [ $arq == "armv7l" ]; then
        # on RaspberryPi 2 or higher
        echo "armv7l"

        # Bullseye does not support omxplayer anymore so we need to install it from the raspberry archive
        if [ ! -x /usr/bin/omxplayer ]; then
          echo -e "\nInstalling omxplayer"
          OPPACKG=omxplayer_20190723+gitf543a0d-1_armhf.deb
          OPARCHIVE=/var/cache/apt/archives/$OPPACKG
          curl -s https://archive.raspberrypi.org/debian/pool/main/o/omxplayer/$OPPACKG | \
          sudo tee $OPARCHIVE > /dev/null && sudo dpkg --install $OPARCHIVE
        fi

        # Bullseye does not provide the libraries needed for omxplayer so we might have to install them here
        if [ ! -r /opt/vc/lib/libbrcmGLESv2.so ]; then
         echo -e "\nInstalling Raspberry Pi videocore"
         git clone --depth=1 --branch=master https://github.com/raspberrypi/firmware.git /tmp/firmware
          sudo mv /tmp/firmware/opt/vc /opt
          rm -rf /tmp/firmware
        fi

    elif [ $arq == "armv6l" ]; then
        # on RaspberryPi 1 (A+, B+)
        echo "armv6l"

        sudo apt-get install -y omxplayer

    else
        # Non-arm7 Debian...
        echo "non armv7l"
        
        sudo apt-get install -y omxplayer
    fi

elif [ $os == "Darwin" ]; then
    # OSX
    echo "osx"
fi
