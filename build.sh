# Compile plain-text AppleScript files to .scpt files and place them in
# the user's Script Libraries folder
set -e
USER_SCRIPT_LIBRARY_FOLDER=~/Library/Script\ Libraries
USER_SCRIPT_FOLDER=~/Library/Scripts

# Compile and place the Script Library files
mkdir -p "$USER_SCRIPT_LIBRARY_FOLDER"
osacompile -o "$USER_SCRIPT_LIBRARY_FOLDER"/My\ Display\ Utilities.scpt My\ Display\ Utilities.applescript

# Compile and place the Script files.  These will appear in the User's Script menu
osacompile -o "$USER_SCRIPT_FOLDER"/Change\ Resoultion.scpt Change\ Resolution.applescript
