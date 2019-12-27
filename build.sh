# Compile plain-text AppleScript files to .scpt files and place them in
# the user's Script Libraries folder
set -e
USER_SCRIPT_LIBRARY=~/Library/Script\ Libraries
mkdir -p "$USER_SCRIPT_LIBRARY"
osacompile -o "$USER_SCRIPT_LIBRARY"/My\ Error\ Codes.scpt My\ Error\ Codes.applescript
osacompile -o "$USER_SCRIPT_LIBRARY"/My\ Display\ Utilities.scpt My\ Display\ Utilities.applescript
