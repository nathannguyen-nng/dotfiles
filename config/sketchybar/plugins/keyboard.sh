#!/bin/bash

# this is jank and ugly, I know
LAYOUT="$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | awk '/KeyboardLayout Name/ {print $4} /"Input Mode"/ && /Vietnamese/ {print "Vietnamese"}' | tr -d '"' | sed '/^$/d')"

# specify short layouts individually.
case "$LAYOUT" in
    "Vietnamese") SHORT_LAYOUT="VI";;
    "U.S.;") SHORT_LAYOUT="US";;
esac

sketchybar --set keyboard label="$SHORT_LAYOUT"
