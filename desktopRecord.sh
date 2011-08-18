#!/bin/bash
#set -x

# Recording desktop This program expects kdialog, ffmpeg, xwininfo and wish to
# be installed. This for showing info on X. Also it disables my background
# changer I have.

#Button location. Uncomment what you want. Comment out what you do not want
BUTTON="-0-0" #Left Bottom
#BUTTON="+0-0" #Right Bottom
#BUTTON="+0+0" #Right Top
#BUTTON="-0+0" #Left Top

#Location to save the file. See `ffmpeg -formats` for formats
DIR=~/
FORMAT=flv

# No changes needed below this point
DATE=`date +%F_%T`
FILE=$DIR/screencapture_${DATE}.${FORMAT}
test -f $FILE && rm $FILE
TMP=`mktemp`

#Determine the screen size and location
PARAM=`xwininfo|egrep 'Width|Height|Corners'|awk '{print $2}'`
WIDTH=`echo $PARAM|awk '{print $1}'`
HEIGHT=`echo $PARAM|awk '{print $2}'`
DIFF=`echo $PARAM|awk '{print $3}'|cut -c2-|sed 's/+/,/g'`
#Check if it is inside the screen
OUTSIDE=`echo $DIFF| grep \-`
if [ -n "$OUTSIDE" ]
then
zenity --error --text="The program you try to recordis (partly) ouside the screen.Drag it inside and try again,or try again by clicking on the desktop itself."
rm $TMP
exit
fi
SIZE="${WIDTH}x${HEIGHT}"
#The actual recording
ffmpeg -loglevel quiet -f x11grab -s "$SIZE" -r 25 -i ${DISPLAY}+${DIFF} -sameq $FILE &

# Make a temporary command that shows a button to end the recording
cat > $TMP <<-EOF
#!/usr/bin/wish
wm geometry . 200x60${BUTTON}
button .message -bd 0 -text "End Recording" -command exit
pack .message
EOF
chmod +x $TMP && $TMP

#Close and cleanup
kill -9 `ps ux | awk '/ffmpeg/ && !/awk/ {print $2}'`
rm $TMP
#mplayer $FILE
