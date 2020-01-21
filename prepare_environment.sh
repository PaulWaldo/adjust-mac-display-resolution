# Create a testing environment where script libraries are loaded from this location
# See https://stackoverflow.com/questions/35389058/why-wont-osa-library-path-not-work-as-documented-for-jxa
# "The OSA_LIBRARY_PATH environment variable is ignored by restricted executables when running with System Integrity Protection enabled."
set -e

cp /usr/bin/osascript ./my_osascript
/usr/bin/codesign -f -s - ./my_osascript
cp /usr/bin/osacompile ./my_osacompile
/usr/bin/codesign -f -s - ./my_osacompile
