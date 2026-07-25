#!/usr/bin/env bash
ACTION="$1"

case "$ACTION" in
  rewind)
    JS="(function(){var v=document.querySelector('video');if(v){v.currentTime=Math.max(0,v.currentTime-10)}})();"
    ;;
  forward)
    JS="(function(){var v=document.querySelector('video');if(v){v.currentTime=v.currentTime+10}})();"
    ;;
  *)
    exit 1
    ;;
esac

osascript <<APPLESCRIPT
tell application "Safari"
    do JavaScript "$JS" in front document
end tell
APPLESCRIPT
