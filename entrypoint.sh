#!/usr/bin/env bash

# Install dependencies
echo "Checking/installing dependencies..."


CHANGED_FILES=$(git diff --name-only HEAD^ HEAD | grep -v "^src/validate*")
echo "The following files were changed: \n$CHANGED_FILES"

# Run configurations
STABLE_RELEASE="95cec2d81c50722abbfcd46957ab184c3c767cf3"
CLONE_DIR="regexploit"

git clone https://github.com/meekdenzo/regexploit.git $CLONE_DIR
cd $CLONE_DIR
git checkout $STABLE_RELEASE
VULN_REGEX_DETECTOR_ROOT=$(pwd)
export VULN_REGEX_DETECTOR_ROOT

python3 -m venv .env
source .env/bin/activate
pip install regexploit

cd ..

# Scan for redos
VULN_COUNT=0
SECONDS=0
for i in ${CHANGED_FILES}
    do
        # echo "Scanning for vulnerable regexes in $i"
        # echo '{"file":"'"$i"'"}' > checkfile.json
       
        # perl ./$CLONE_DIR/bin/check-file.pl checkfile.json > checkfile-out.json

        # echo "The following vulnerable regexes were found in $i"
        # jq -r '.vulnRegexes | .[]?' < checkfile-out.json
        # printf "\n\n\n\n"

        # COUNT=$(jq '.anyVulnRegexes' < checkfile-out.json)
        # VULN_COUNT=$((VULN_COUNT+$COUNT))

        cat $i | regexploit

    done
duration=$SECONDS;
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed for scan."

# if [ $VULN_COUNT -eq 0 ]; then
#     echo "No vulnerable regex was detected. You're good to go!"
# else
#     echo "$VULN_COUNT vulnerable regex(es) were detected. See logs above."
#     exit 10
# fi