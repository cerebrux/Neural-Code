#!/bin/bash

# Ubuntu After Install
#
# Version: 1.4 Beta
# 2013-03-28
#
# By The Fan Club 2013 
# http://www.thefanclub.co.za 
# 
echo 
echo "*** Ubuntu After Install by The Fan Club"
echo          
echo "* NOTE: This program downloads, downloads and installs various tweak and software,"
echo "        after an fresh Ubuntu install - adding some much needed extras." 
echo       
echo "* NOTE: Before you will be able to run  this script you will need to"
echo "        make it executable : sudo chmod +x /path/to/script/ubuntu-after-install" 
echo "* NOTE: Run this script as root with: sudo sh /path/to/script/ubuntu-after-install"
echo
echo "* DISCLAIMER: This script is provided purely for testing use. Use at own risk."
echo 
#
# Local Vars
TFCName="Ubuntu After Install"
TFCVersion="v1.4 beta"
LogDay=$(date '+%Y-%m-%d')
LogTime=$(date '+%Y-%m-%d %H:%M:%S')
logFile=/var/log/ubuntu-after-install_$LogDay.log
userName=$(eval echo $SUDO_USER)
ubuntuVerRelT=$(cat /etc/lsb-release | awk 'BEGIN {FS="DISTRIB_RELEASE="} {print $2;}') 
ubuntuVerRel=$(echo $ubuntuVerRelT)
installChkLog=()

#
# Select Desktop Tweak Tool Depending on Ubuntu Version
if [ $(echo "$ubuntuVerRel < 12.04" | bc ) -eq 1 ]
  then
    tweakTool="Gnome Tweak Tool"
fi
if [ "$ubuntuVerRel" = "12.04" ] 
  then
    tweakTool="MyUnity"
fi
if [ "$ubuntuVerRel" = "12.10" ] 
  then
    tweakTool="Unity Tweak Tool *"
fi
# Use BC to do floating point calcs
if [ $(echo "$ubuntuVerRel > 12.10" | bc ) -eq 1 ] 
  then
    tweakTool="Unity Tweak Tool"
fi
#
# Functions
## Check if software is installed
FINSTALLED() {
   checkInstall=$(dpkg -s $* | grep -i "Status")   
   checkOk=$(echo "$checkInstall" | grep -i -o "ok")
   if [ ! "$checkOk" ] 
     then
       echo "false"
     else
       echo "true"
   fi
}

FINSTALLOK () {
   # Build Array
   if [ "$installChkLog" = "" ] 
     then 
       # First item
       installChkLog=( TRUE "$*" Ok )
     else
       # Append Array
       installChkLog+=( TRUE "$*" Ok )
   fi
}

FINSTALLERR () {
   # Build Array
   if [ "$installChkLog" = "" ] 
     then 
       # First item
       installChkLog=( TRUE "$*" Error )
     else
       # Append Array
       installChkLog+=( TRUE "$*" Error )
   fi
}

## Add new launcher items on unity sidebar 
FADDLAUNCHER() {
   newLauncher="'application:\/\/$*.desktop'"
   currentList=`sudo -u $userName gsettings get com.canonical.Unity.Launcher favorites`
   checkList=$(echo $currentList | grep $* )
   if [ ! "$checkList" ]
     then
       newList=$(echo $currentList | sed s/]/", $newLauncher]"/ )
       sudo -u $userName gsettings set com.canonical.Unity.Launcher favorites "$newList"
   fi
}



#
# Start of Zenity code 
#
selection=$(zenity  --list  --title "The Fan Club - $TFCName" --text "<b>Select the after installs you require</b>\n* PPA added during installation" --checklist  --width=550 --height=600 \
--column "Select" --column "Software" --column="Description" \
TRUE "System Software Update" "System Update" \
TRUE "Restricted Multimedia Extras" "Video codecs" \
TRUE "$tweakTool" "Desktop Settings" \
TRUE "Faenza *" "Icon Theme" \
TRUE "XScreenSaver" "Screensaver" \
TRUE "My Weather Indicator *" "Weather App" \
TRUE "Calendar Indicator *" "Google Calendar" \
TRUE "Google Chrome *" "Browser" \
TRUE "LibreOffice *" "Office Suite" \
TRUE "Skype" "Instant Messenger" \
TRUE "DropBox" "File Sharing" \
TRUE "VLC" "Media Player" \
TRUE "XBMC *" "Media Center" \
TRUE "GIMP *" "Image Editor" \
TRUE "Darktable *" "Image Processor" \
TRUE "Inkscape" "Vector Graphics Editor" \
TRUE "Scribus" "Desktop Publishing" \
TRUE "Samba" "Windows File Sharing" \
TRUE "PDF Tools" "Edit PDF's" \
TRUE "SSH Server" "Remote Access" \
TRUE "Vinagre" "Remote Desktop" \
TRUE "FileZilla" "FTP Client" \
TRUE "OpenShot" "Video Editor" \
TRUE "Kdenlive" "Video Editor" \
TRUE "HandBrake *" "Video Transcoder" \
TRUE "Audacity" "Sound Editor" \
TRUE "Steam *" "Gaming Platform" \
TRUE "KeyPassX" "Password Manager" \
TRUE "Shutter" "Screenshot Tool" \
--separator=","); 


if [ ! "$selection" = "" ] 
  then
    # Check for dpkg lock - must be sudo to use lsof
    dpkgLock=$(lsof /var/lib/dpkg/lock)
    if [ "$dpkgLock" ]
      then
        # file is locked
        zenity  --question  --title "The Fan Club - $TFCName" --text "<big><b>Installation  manager is busy elsewhere</b></big>\n\nClick <b>Next</b> to force the installation manager to quit and continue" --width=600 --ok-label="Next" --cancel-label="Cancel"
                   
        case $? in
          0)
            # Next
            # Kill process still locking us out of dpkg 
            sudo fuser -vk /var/lib/dpkg/lock
            # Fix half installed packages if needed 
            sudo dpkg --configure -a
            # Now continue installation
            echo "# Installation manager closed"
          ;;
          1)
            # Cancel
            zenity --warning --text="<big><b>Software installation cancelled</b></big>\n\nThis application will now close." --title="The Fan Club - $TFCName" --width=500
            exit
	  ;;
         -1)
            echo "# An unexpected error has occurred."
            exit
	  ;;
        esac 
    fi

    # Check for apt lists lock - must be sudo to use lsof
    aptLock=$(lsof /var/lib/apt/lists/lock)
    if [ "$aptLock" ]
      then
        # file is locked
        zenity  --question  --title "The Fan Club - $TFCName" --text "<big><b>Update  manager is busy elsewhere</b></big>\n\nClick <b>Next</b> to force the update manager to quit and continue" --width=600 --ok-label="Next" --cancel-label="Cancel"
                   
        case $? in
          0)
            # Next
            # Kill process still locking us out of dpkg 
            sudo fuser -vk /var/lib/apt/lists/lock
            # Now continue installation
            echo "# Update manager closed"
          ;;
          1)
            # Cancel
            zenity --warning --text="<big><b>Software installation cancelled</b></big>\n\nThis application will now close." --title="The Fan Club - $TFCName" --width=500
            exit
	  ;;
         -1)
            echo "# An unexpected error has occurred."
            exit
	  ;;
        esac 
    fi

    # Start of Main Zenity Progress code 
    echo "$LogTime uss: [$userName] * $TFCName $TFCVersion - Install Log Started" >> $logFile
    (
    # Count items selected comma seperated values with awk
    installCount=$(echo $selection | awk -F, '{print NF}')
    # Set Counter increments
    progressBarVal=0
    taskNum=1
    counterInc=$(echo "scale=0; 100/$installCount" | bc )
    # Counter set to 0 for 1st item

    # 0. Activate Ubuntu Partner Repository at start as so many installs depend on it
    echo "$progressBarVal" ; sleep 0.1
       echo "$LogTime uss: [$userName] 0. Activate Ubuntu Partner Repository" >> $logFile
       echo "# $progressBarVal% completed. Installation Started"
       # Add Partners to Repo List
       sudo sed -i "/^# deb .*partner/ s/^# //" /etc/apt/sources.list
       sudo sed -i "/^# deb-src .*partner/ s/^# //" /etc/apt/sources.list

       # Update Repos
       sudo apt-get update 2>&1 | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Updating Software Center ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
      
       echo "# Ubuntu Partner Repository activated"  
      

    # 1. Post Install Software Update
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "System")
       if [ "$option" -eq "1" ] 
         then
           echo "$LogTime uss: [$userName] 1. Software Update" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Software Update"

           # Post install update
           # apt-get upgrade already done during partner ad in step 0
           sudo apt-get -y upgrade 2>&1 | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing software updates ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Fix possible update issues
sudo apt-get -y -f install 2>&1 | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Verifying installation ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Update progress bar value and tasks done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - System updated"  
           taskNum=$(expr $taskNum + 1 )  
       fi

    # 2. Install Restricted Extras
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Restricted")      
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "ubuntu-restricted-extras" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "Ubuntu Restricted Extras"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount - Restricted Extras already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ] 
         then
           echo "$LogTime uss: [$userName] 2. Install Restricted Extras" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install Restricted Extras"
           # Accept MS EULA
           sudo sh -c "echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections"
           # Install MS Core Fonts first
           sudo apt-get install -y ttf-mscorefonts-installer --quiet 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing MS Core Fonts ...</b></big>"  --width=500 --pulsate --no-cancel --auto-close
           # Install restricted extras
           sudo apt-get install -y ubuntu-restricted-extras 2>&1 | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing Restricted Extras ...</b></big>"  --width=500 --pulsate --no-cancel --auto-close
           # Install Medibuntu PPA
           ## Medibuntu
           
           sudo wget --output-document=/etc/apt/sources.list.d/medibuntu.list http://www.medibuntu.org/sources.list.d/$(lsb_release -cs).list 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Adding Medibuntu PPA ...</b></big>"  --width=500 --pulsate --no-cancel --auto-close 
           ## update apt list
           sudo apt-get --quiet update 2>&1 | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Updating Software Center ...</b></big>"  --width=500 --pulsate --no-cancel --auto-close 
           
           sudo apt-get --yes --quiet --allow-unauthenticated install medibuntu-keyring 2>&1 | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing Medibuntu PPA Key ...</b></big>"  --width=500 --pulsate --no-cancel --auto-close 
           ## Enable DVD playback 
           sudo apt-get install -y libdvdcss2 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Enabling DVD playback ...</b></big>"  --width=500 --pulsate --no-cancel --auto-close
           
           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying Restricted Extras installation ..."
           installStatus=$( FINSTALLED "ubuntu-restricted-extras" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "Ubuntu Restricted Extras"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "Ubuntu Restricted Extras"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - Ubuntu Restricted Extras installed"  
           taskNum=$(expr $taskNum + 1 )
       fi

    # 3. Install Tweak Tool Depending on Ubuntu Version
    echo "$progressBarVal" ; sleep 0.1

       ## Gnome Tweak Tool for all before 12.04
       option=$(echo $selection | grep -c "Gnome Tweak Tool")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "gnome-tweak-tool" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "Gnome Tweak Tool"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  Gnome Tweak Tool already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]
         then
           echo "$LogTime uss: [$userName] 3. Gnome Tweak Tool" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install Gnome Tweak Tool"  
           # Install Tweak Tool
           sudo apt-get install -y gnome-tweak-tool 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing Gnome Tweak Tool ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying Gnome Tweak Tool installation ..."
           installStatus=$( FINSTALLED "gnome-tweak-tool" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "Gnome Tweak Tool"
               # Add desktop launcher to sidebar
               FADDLAUNCHER "gnome-tweak-tool"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "Gnome Tweak Tool"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - Gnome Tweak Tool installed"  
           taskNum=$(expr $taskNum + 1 )  
       fi

       ## MyUnity for 12.04
       option=$(echo $selection | grep -c "MyUnity")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "myunity" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "MyUnity"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  MyUnity already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ] 
         then
           echo "$LogTime uss: [$userName] 3. Install MyUnity" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install MyUnity"  
           # Install Tweak Tool
           sudo apt-get install -y myunity 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing MyUnity ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying MyUnity installation ..."
           installStatus=$( FINSTALLED "myunity" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "MyUnity"
               # Add desktop launcher to sidebar
               FADDLAUNCHER "myunity"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "MyUnity"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - MyUnity installed"  
           taskNum=$(expr $taskNum + 1 )
        fi

        ## Unity Tweak Tool for 12.10 with PPA and 12.10 native 
        option=$(echo $selection | grep -c "Unity Tweak Tool")
        # Check if option selected 
        if [ "$option" -eq "1" ] 
          then
            # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
            installStatus=$( FINSTALLED "unity-tweak-tool" )
            if [ "$installStatus" = "true" ] 
              then
                # install ok add to ok list
                echo "$LogTime uss: [$userName] [OK] Already Installed" >> $logFile
                FINSTALLOK "Unity Tweak Tool"
                # Update progress bar value anyway 
                progressBarVal=$(expr $progressBarVal + $counterInc )  
                echo "# $progressBarVal% completed. $taskNum of $installCount -  Unity Tweak Tool already installed"  
                taskNum=$(expr $taskNum + 1 )
            fi
        fi
        # If option selected and not installed continue    
        if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]
          then
            # Install PPA for Ubuntu 12.10 
            if [ "$ubuntuVerRel" = "12.10" ] 
              then
                # Add Unity Tweak Tool Daily PPA to Repo List
                sudo add-apt-repository -y ppa:freyja-dev/unity-tweak-tool-daily 2>&1 | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Adding Unity Tweak Tool PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
                # Update Repos
                sudo apt-get --quiet update 2>&1 | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Updating Software Center ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
                # Unity Tweak Tool Repository activated
            fi
            # Install Tweak Tool
            echo "$LogTime uss: [$userName] 3. Install Unity Tweak Tool" >> $logFile
            echo "# $progressBarVal% completed. $taskNum of $installCount - Install Unity Tweak Tool"  
            sudo apt-get install -y unity-tweak-tool 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing Unity Tweak Tool ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying Unity Tweak Tool installation ..."
           installStatus=$( FINSTALLED "unity-tweak-tool" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "Unity Tweak Tool"
               # Add desktop launcher to sidebar
               FADDLAUNCHER "unity-tweak-tool"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "Unity Tweak Tool"
           fi

            # Update progress bar value when done
            progressBarVal=$(expr $progressBarVal + $counterInc )  
            echo "# $progressBarVal% completed. $taskNum of $installCount - Unity Tweak Tool installed"  
            taskNum=$(expr $taskNum + 1 )
        fi

    # 4. Install Faenza Icon Theme
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Faenza")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "faenza-icon-theme" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "Faenza Icon Theme"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount - Faenza Icon Theme already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ] 
         then
           echo "$LogTime uss: [$userName] 4. Install Faenza Icon Theme" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install Faenza Icon Theme"
           # Add WebUp8 PPA to Repo List
           sudo add-apt-repository -y -y ppa:webupd8team/themes 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Adding WebUp8 PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Update Repos
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Updating Software Center ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Install Faenza Icon Theme
           sudo apt-get install -y faenza-icon-theme 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing Faenza icon theme ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying Faenza Icon Theme installation ..."
           installStatus=$( FINSTALLED "faenza-icon-theme" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "Faenza Icon Theme"
               # Set Faenza as default icons
               sudo -u $userName gsettings set org.gnome.desktop.interface icon-theme "Faenza-Dark"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "Faenza Icon Theme"
           fi


           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - Faenza Icon Theme installed"
           taskNum=$(expr $taskNum + 1 )
        fi

    # 4.1 Install XScreenSaver
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "XScreenSaver")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "xscreensaver" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "XScreenSaver"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  XScreenSaver already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]  
         then
           echo "$LogTime uss: [$userName] 4.1 Install XScreenSaver" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install XScreenSaver"  
           # Remove Gnome Screensaver
           sudo apt-get remove -y gnome-screensaver 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Removing Gnome Screensaver ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Install XScreenSaver
           sudo apt-get install -y xscreensaver xscreensaver-gl-extra xscreensaver-data-extra 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing XScreenSaver ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying XScreenSaver installation ..."
           installStatus=$( FINSTALLED "xscreensaver" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "XScreenSaver"
               # Create Autostart Desktop Entry for XScreeSaver
               sudo echo "[Desktop Entry]" >> /etc/xdg/autostart/screensaver.desktop
               sudo echo "Name=Screensaver" >> /etc/xdg/autostart/screensaver.desktop 
               sudo echo "Type=Application" >> /etc/xdg/autostart/screensaver.desktop
               sudo echo "Exec=xscreensaver -nosplash" >> /etc/xdg/autostart/screensaver.desktop
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "XScreenSaver"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - XScreenSaver installed"  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 4.2 Install My Weather Indicator
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Weather")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "my-weather-indicator" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "My Weather Indicator"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  My Weather Indicator already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ] 
         then
           echo "$LogTime uss: [$userName] 4.2 Install My Weather Indicator" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install My Weather Indicator"  
           # Add My Weather Indicator PPA to Repo List
           sudo add-apt-repository -y ppa:atareao/atareao 2>&1 | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Adding My Weather Indicator PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Update Repos
           sudo apt-get --quiet update 2>&1 | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Updating Software Center ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Install My Weather Indicator
           sudo apt-get install -y my-weather-indicator 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing My Weather Indicator ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying My Weather Indicator installation ..."
           installStatus=$( FINSTALLED "my-weather-indicator" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "My Weather Indicator"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "My Weather Indicator"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - My Weather Indicator installed"  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 4.3 Install Calendar Indicator
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Calendar")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "calendar-indicator" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "Calendar Indicator"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  Calendar Indicator already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ] 
         then
           echo "$LogTime uss: [$userName] 4.3 Install Calendar Indicator" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install Calendar Indicator"  
           # Check to see if Weather Indicator is also installed to skip adding the ppa again
           option=$(echo $selection | grep -c "Weather")
           if [ "$option" -eq "0" ] 
             then
               # Add Calendar Indicator PPA to Repo List
               sudo add-apt-repository -y ppa:atareao/atareao 2>&1 | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Adding Calendar Indicator PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
               # Update Repos
               sudo apt-get --quiet update 2>&1 | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Updating Software Center ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           fi
           # Install Calendar Indicator
           sudo apt-get install -y calendar-indicator 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing Calendar Indicator ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying Calendar Indicator installation ..."
           installStatus=$( FINSTALLED "calendar-indicator" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "Calendar Indicator"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "Calendar Indicator"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - Calendar Indicator installed"  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 5. Install Google Chrome
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Chrome")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "google-chrome-stable" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "Google Chrome"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  Google Chrome already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ] 
         then
           echo "$LogTime uss: [$userName] 5. Install Google Chrome" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install Google Chrome"
           # Add Google PPA to Repo List
           wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
           sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' 
           # Update Repos
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Updating Software Center ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Install Google Chrome
           sudo apt-get install -y google-chrome-stable 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing Google Chrome ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying Google Chrome installation ..."
           installStatus=$( FINSTALLED "google-chrome-stable" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "Google Chrome"
               # Add desktop launcher to sidebar
               FADDLAUNCHER "google-chrome"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "Google Chrome"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - Google Chrome installed"  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 6. Install LibreOffice 4
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "LibreOffice")
       if [ "$option" -eq "1" ] 
         then
           echo "$LogTime uss: [$userName] 6. Install LibreOffice" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install LibreOffice"  
           # Add LibreOffice PPA to Repo List
           sudo add-apt-repository -y ppa:libreoffice/ppa 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Adding LibreOffice PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Update Repos
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Updating Software Center ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Install LibreOffice
           sudo apt-get -y dist-upgrade 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing LibreOffice ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Fix possible update issues
sudo apt-get -y -f install 2>&1 | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Verifying installation ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying LibreOffice installation ..."
           installStatus=$( FINSTALLED "libreoffice" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "LibreOffice"
               # Add desktop launcher to sidebar
               FADDLAUNCHER "libreoffice-startcenter"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "LibreOffice"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - LibreOffice installed"  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 7. Install Skype
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Skype")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "skype" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "Skype"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  Skype already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]  
         then
           echo "$LogTime uss: [$userName] 7. Install Skype" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install Skype"  
           # Install Skype
           sudo apt-get install -y skype 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing Skype ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying Skype installation ..."
           installStatus=$( FINSTALLED "skype" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "Skype"
               # Add desktop launcher to sidebar
               FADDLAUNCHER "skype"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "Skype"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - Skype installed"  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 8. Install DropBox
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "DropBox")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "nautilus-dropbox" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "DropBox"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  DropBox already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ] 
          then
            echo "$LogTime uss: [$userName] 8. Install DropBox" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install DropBox"  
            # Install DropBox
            sudo apt-get install -y nautilus-dropbox 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing DropBox ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying DropBox installation ..."
           installStatus=$( FINSTALLED "nautilus-dropbox" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "DropBox"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "DropBox"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - DropBox installed"  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 9. Install VLC
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "VLC")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "vlc" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "VLC"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  VLC already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]  
         then
           echo "$LogTime uss: [$userName] 9. Install VLC" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install VLC"  
           # Install VLC
           sudo apt-get install -y vlc 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing VLC ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying VLC installation ..."
           installStatus=$( FINSTALLED "vlc" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "VLC"
               # Add desktop launcher to sidebar
               FADDLAUNCHER "vlc"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "VLC"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - VLC installed"  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 10. Install XBMC
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "XBMC")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "xbmc" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "XBMC"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  XBMC already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Install XBMC" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install XBMC"  
           # Add XBMC PPA to Repo List
           sudo add-apt-repository -y ppa:team-xbmc/ppa 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Adding XBMC PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Update Repos
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Updating Software Center ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Install XBMC
           sudo apt-get install -y xbmc xbmc-standalone 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing XBMC ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying XBMC installation ..."
           installStatus=$( FINSTALLED "xbmc" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "XBMC"
               # Add desktop launcher to sidebar
               FADDLAUNCHER "xbmc"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "XBMC"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - XBMC installed"  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 11. Install GIMP
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "GIMP")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "gimp" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "GIMP"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  GIMP already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]    
         then
           echo "$LogTime uss: [$userName] 11. Install GIMP" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install GIMP"  
           # Add GIMP PPA to Repo List
           sudo add-apt-repository -y ppa:otto-kesselgulasch/gimp 2>&1 | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Adding GIMP PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Update Repos
           sudo apt-get --quiet update 2>&1 | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Updating Software Center ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Install GIMP
           sudo apt-get install -y gimp 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing GIMP ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying GIMP installation ..."
           installStatus=$( FINSTALLED "gimp" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "GIMP"
               # Add desktop launcher to sidebar
               FADDLAUNCHER "gimp"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "GIMP"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - GIMP installed"  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 11.1 Install Darktable
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Darktable")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "darktable" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "Darktable"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  Darktable already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]    
         then
           echo "$LogTime uss: [$userName] 11.1 Install Darktable" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install Darktable"  
           # Install PPA for versions before 13.04 as ppa has not been updated yet
           if [ $(echo "$ubuntuVerRel < 13.04" | bc ) -eq 1 ] 
             then
               # Add Darktable PPA to Repo List
               sudo add-apt-repository -y ppa:pmjdebruijn/darktable-release 2>&1 | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Adding Darktable PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
               # Update Repos
               sudo apt-get --quiet update 2>&1 | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Updating Software Center ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           fi
           ## Install Quantal PPA for Raring as PPA is not updated yet - NOTE: Temporary
           if [ $(echo "$ubuntuVerRel == 13.04" | bc ) -eq 1 ] 
             then
               sudo add-apt-repository -y 'deb http://ppa:pmjdebruijn/darktable-release quantal main'  2>&1 | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Adding Darktable PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
               # Update Repos
               sudo apt-get --quiet update 2>&1 | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Updating Software Center ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           fi
           # Install Darktable
           sudo apt-get install -y darktable 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing Darktable ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying Darktable installation ..."
           installStatus=$( FINSTALLED "darktable" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "Darktable"
               # Add desktop launcher to sidebar
               FADDLAUNCHER "darktable"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "Darktable"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - Darktable installed"  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 12. Install Inkscape
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Inkscape")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "inkscape" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "Inkscape"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  Inkscape already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]    
          then
            echo "$LogTime uss: [$userName] 12. Install Inkscape" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install Inkscape"  
            # Install Inkscape
            sudo apt-get install -y inkscape 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing Inkscape ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying Inkscape installation ..."
           installStatus=$( FINSTALLED "inkscape" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "Inkscape"
               # Add desktop launcher to sidebar
               FADDLAUNCHER "inkscape"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "Inkscape"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - Inkscape installed"  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 13. Install Scribus
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Scribus")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "scribus" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "Scribus"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  Scribus already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]    
         then
           echo "$LogTime uss: [$userName] 13. Install Scribus" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install Scribus"  
           # Install Scribus
           sudo apt-get install -y scribus 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing Scribus ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying Scribus installation ..."
           installStatus=$( FINSTALLED "scribus" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "Scribus"
               # Add desktop launcher to sidebar
               FADDLAUNCHER "scribus"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "Scribus"
           fi


           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - Scribus installed"  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 14. Install SAMBA
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Samba")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "samba" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "Samba"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  Samba already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]    
         then
           echo "$LogTime uss: [$userName] 14. Install SAMBA" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install Samba"  
           # Install SAMBA
           sudo apt-get install -y samba samba-common libpam-smbpass winbind smbclient libcups2 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing Samba</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying Samba installation ..."
           installStatus=$( FINSTALLED "samba" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "Samba"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "Samba"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - Samba installed"  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 15. Install PDF Tools
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "PDF")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "pdfmod" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "PDF Tools"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  PDF tools already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
          then
            echo "$LogTime uss: [$userName] 15. Install PDF Tools" >> $logFile
            echo "# $progressBarVal% completed. $taskNum of $installCount - Install PDF Tools"  
            # Install PDF Tools
            sudo apt-get install -y pdfmod pdfshuffler pdfchain 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing PDF Tools ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying PDF Tools installation ..."
           installStatus=$( FINSTALLED "pdfmod" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "PDF Tools"
               # Add desktop launcher to sidebar
               FADDLAUNCHER "pdfmod"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "PDF Tools"
           fi

            # Update progress bar value when done
            progressBarVal=$(expr $progressBarVal + $counterInc )  
            echo "# $progressBarVal% completed. $taskNum of $installCount - PDF Tools installed"  
            taskNum=$(expr $taskNum + 1 )
        fi

    # 16. Install SSH Server
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "SSH")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "openssh-server" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "SSH Server"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  SSH Server already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]    
         then
           echo "$LogTime uss: [$userName] 16. Install SSH Server" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install SSH Server"  
           # Install SSH Server
           sudo apt-get install -y openssh-server 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing SSH Server ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying SSH Server installation ..."
           installStatus=$( FINSTALLED "openssh-server" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "SSH Server"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "SSH Server"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - SSH Server installed"  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 16.1 Install Vinagre
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Vinagre")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "vinagre" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "Vinagre"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  Vinagre already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ] 
         then
           echo "$LogTime uss: [$userName] 16.1 Install Vinagre" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install Vinagre"  
           # Install Vinagre
           sudo apt-get install -y vinagre 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing Vinagre ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying Vinagre installation ..."
           installStatus=$( FINSTALLED "vinagre" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "Vinagre"
               # Add desktop launcher to sidebar
               FADDLAUNCHER "vinagre"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "Vinagre"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - Vinagre installed"  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 17. Install FileZilla
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "FileZilla")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "filezilla" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "FileZilla"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  FileZilla already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ] 
         then
           echo "$LogTime uss: [$userName] 17. Install FileZilla" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install FileZilla"  
           # Install FileZilla
           sudo apt-get install -y filezilla 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing FileZilla</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying FileZilla installation ..."
           installStatus=$( FINSTALLED "filezilla" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "FileZilla"
               # Add desktop launcher to sidebar
               FADDLAUNCHER "filezilla"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "FileZilla"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - FileZilla installed"  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 20.0 Install OpenShot
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "OpenShot")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "openshot" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "OpenShot"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  OpenShot already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]  
         then
           echo "$LogTime uss: [$userName] 20.0 Install OpenShot" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install OpenShot"  
           # Install OpenShot
           sudo apt-get install -y openshot 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing OpenShot ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying OpenShot installation ..."
           installStatus=$( FINSTALLED "openshot" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "OpenShot"
               # Add desktop launcher to sidebar
               FADDLAUNCHER "openshot"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "OpenShot"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - OpenShot installed"  
           taskNum=$(expr $taskNum + 1 )
       fi

    # 20.1 Install Kdenlive
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Kdenlive")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "kdenlive" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "Kdenlive"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  Kdenlive already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]  
         then
           echo "$LogTime uss: [$userName] 20.1 Install Kdenlive" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install Kdenlive"  
           # Install Kdenlive
           sudo apt-get install -y kdenlive 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing Kdenlive ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying Kdenlive installation ..."
           installStatus=$( FINSTALLED "kdenlive" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "Kdenlive"
               # Add desktop launcher to sidebar
               FADDLAUNCHER "kde4-kdenlive"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "Kdenlive"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - Kdenlive installed"  
           taskNum=$(expr $taskNum + 1 )
       fi

    # 21. Install HandBrake
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "HandBrake")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "handbrake-gtk" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "HandBrake"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  HandBrake already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]  
         then
           echo "$LogTime uss: [$userName] 21. Install HandBrake" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install Handbrake"  
           # Add Handbrake PPA to Repo List

           ## Add for all before 13.04
           if [ $(echo "$ubuntuVerRel < 13.04" | bc ) -eq 1 ] 
             then
               sudo add-apt-repository -y ppa:stebbins/handbrake-releases  2>&1 | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Adding HandBrake PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
               # Update Repos
               sudo apt-get --quiet update 2>&1 | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Updating Software Center ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           fi
           ## Add Quantal for Raring because PPA is not updated yet NOTE : Temporary
           if [ $(echo "$ubuntuVerRel == 13.04" | bc ) -eq 1 ] 
             then
               sudo add-apt-repository -y 'deb http://ppa.launchpad.net/stebbins/handbrake-releases/ubuntu quantal main'  2>&1 | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Adding HandBrake PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
               # Update Repos
               sudo apt-get --quiet update 2>&1 | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Updating Software Center ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           fi
          
           # Install Handbrake
           sudo apt-get install -y handbrake-gtk 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing HandBrake ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying Handbrake installation ..."
           installStatus=$( FINSTALLED "handbrake-gtk" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "Handbrake"
               # Add desktop launcher to sidebar
               FADDLAUNCHER "ghb"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "Handbrake"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - Handbrake installed"  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 22. Install Audacity
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Audacity")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "audacity" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "Audacity"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  Audacity already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ] 
         then
           echo "$LogTime uss: [$userName] 22. Install Audacity" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install Audacity"  
           # Install Audacity
           sudo apt-get install -y audacity 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing Audacity ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying Audacity installation ..."
           installStatus=$( FINSTALLED "audacity" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "Audacity"
               # Add desktop launcher to sidebar
               FADDLAUNCHER "audacity"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "Audacity"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - Audacity installed"  
           taskNum=$(expr $taskNum + 1 )
       fi

    # 23. Install Steam
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Steam")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "steam" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "Steam"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  Steam already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]  
         then
           echo "$LogTime uss: [$userName] 23. Install Steam" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install Steam"  
           # Install Steam
           sudo apt-get install -y steam 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing Steam ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying Steam installation ..."
           installStatus=$( FINSTALLED "steam" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "Steam"
               # Add desktop launcher to sidebar
               FADDLAUNCHER "steam"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "Steam"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - Steam installed"  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 24. Install KeePassX
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "KeePassX")
       # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "keepassx" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "KeePassX"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  KeePassX already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]  
         then
           echo "$LogTime uss: [$userName] 24. Install KeePassX" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install KeePassX"  
           # Install KeePassX
           sudo apt-get install -y keepassx 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing KeePassX ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying KeepassX installation ..."
           installStatus=$( FINSTALLED "keepassx" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "KeepassX"
               # Add desktop launcher to sidebar
               FADDLAUNCHER "keepassx"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "KeepassX"
           fi

           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - KeePassX installed"  
           taskNum=$(expr $taskNum + 1 )
       fi

    # 25. Install Shutter
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Shutter")
        # Check if option selected 
       if [ "$option" -eq "1" ] 
         then
           # Check if software is already installed
           echo "# $progressBarVal% completed. $taskNum of $installCount - Checking installed software"
           installStatus=$( FINSTALLED "shutter" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               FINSTALLOK "Shutter"
               # Update progress bar value anyway 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completed. $taskNum of $installCount -  Shutter already installed"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # If option selected and not installed continue    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ] 
         then
           echo "$LogTime uss: [$userName] 24. Install Shutter" >> $logFile
           echo "# $progressBarVal% completed. $taskNum of $installCount - Install Shutter"  
           # Install Shutter
           sudo apt-get install -y shutter 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="The Fan Club - $TFCName" --text="<big><b>Installing Shutter ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Check if software is actually installed ok
           echo "# $progressBarVal% completed. $taskNum of $installCount - Verifying Shutter installation ..."
           installStatus=$( FINSTALLED "shutter" )
           if [ "$installStatus" = "true" ] 
             then
               # install ok add to ok list
               echo "$LogTime uss: [$userName] [OK] Installation Successfull" >> $logFile
               FINSTALLOK "Shutter"
               # Add desktop launcher to sidebar
               FADDLAUNCHER "shutter"
             else
               # install err add to err list
               echo "$LogTime uss: [$userName] [ERROR] Installation Failed" >> $logFile
               FINSTALLERR "Shutter"
           fi
          
           # Update progress bar value when done
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completed. $taskNum of $installCount - Shutter installed" 
           taskNum=$(expr $taskNum + 1 )
       fi

    echo "99"
    echo "# 99% Installation Report" ; sleep 0.1
    
    # After Install Report
    zenity --list --title="$TFCName $TFCVersion - Installation Report" --text="<b>Thank you for using this application</b>\nFor more information visit: <tt><a href='http://www.thefanclub.co.za/node/121'>www.thefanclub.co.za</a></tt>"  --ok-label="Done" --checklist --separator="," --column="Installed" --column="Software" --column="Install" "${installChkLog[@]}" --width=500 --height=600

    echo "# 100% Installation Complete." ; sleep 0.1

    # End of Zenity Progress code
    ) |
    zenity --progress \
           --title="The Fan Club - $TFCName" \
           --text="Installing missing extras..." \
           --width=500 \
           --ok-label="Done" \
           --percentage=0 
           

    if [ "$?" = -1 ] ; then
      zenity --error \
             --text="Installation canceled."
    fi


  fi

# All Done

exit;





