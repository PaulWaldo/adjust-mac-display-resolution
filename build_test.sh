set -e

# Set the Script Library path to include the current directory
OSA_LIBRARY_PATH=$(pwd):$OSA_LIBRARY_PATH
echo $OSA_LIBRARY_PATH

# Compile plain-text AppleScript files to .scpt files in the current folder
./my_osacompile -o "My Display Utilities.scpt" "My Display Utilities.applescript"
./my_osacompile -o "Change Resolution.scpt" "Change Resolution.applescript"

# Run the main script
./my_osascript "Change Resolution.scpt"
