#!/usr/bin/env bash

set -e

# Install dependencies
echo "Checking/installing dependencies..."
command -v curl || sudo apt-get install -yq curl
command -v jq || sudo apt-get install -yq jq

CHANGED_FILES=$(git diff --name-only HEAD^ HEAD | grep -v "^src/validate*")
echo "The following files were changed: \n$CHANGED_FILES"

# Run configurations
STABLE_RELEASE="54ddfd60ced5ea0735ed42b910505fa14d3b41bf"
CLONE_DIR="vuln-regex-detector"

git clone https://github.com/davisjam/vuln-regex-detector.git $CLONE_DIR
cd $CLONE_DIR
git checkout $STABLE_RELEASE
VULN_REGEX_DETECTOR_ROOT=$(pwd)
export VULN_REGEX_DETECTOR_ROOT
./configure
cd ..

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