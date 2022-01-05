#!/usr/bin/env bash

set -e

# Install dependencies
echo "Checking/installing dependencies..."
command -v curl || sudo apt-get install -yq curl
command -v jq || sudo apt-get install -yq jq

CHANGED_FILES=$(git diff --name-only HEAD^ HEAD | grep -v "^src/validate*")
echo "$CHANGED_FILES"

# Run configurations
git clone https://github.com/davisjam/vuln-regex-detector.git
cd vuln-regex-detector
VULN_REGEX_DETECTOR_ROOT=$(pwd)
export VULN_REGEX_DETECTOR_ROOT
./configure
cd ..

# test
echo '{"file":"./autoInject.js"}' > checkfile.json   
perl ./bin/check-file.pl checkfile.json > checkfile-out.json
jq -r '.vulnRegexes | .[]?' < checkfile-out.json
# Scan for redos

SECONDS=0
for i in ${CHANGED_FILES}
    do
        echo "Scanning for vulnerable regexes in $i"
        echo '{"file":"'"$i"'"}' > checkfile.json
       
        perl ./bin/check-file.pl checkfile.json > checkfile-out.json

        echo "The following vulnerable regexes were found in $i"
        jq -r '.vulnRegexes | .[]?' < checkfile-out.json
        printf "\n\n\n\n"
    done
duration=$SECONDS;
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed for scan."