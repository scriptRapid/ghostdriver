#!/bin/bash
#
# This file is part of the GhostDriver by Ivan De Marino <http://ivandemarino.me>.
#
# Copyright (c) 2012, Ivan De Marino <http://ivandemarino.me>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice,
#       this list of conditions and the following disclaimer in the documentation
#       and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Builds all the atoms that will later be imported in GhostDriver
#
# Here we have a mix of:
#
#    * Atoms from the default WebDriver Atoms directory
#    * Atoms that were not exposed by the default build configuration of Selenium
#    * Atoms purposely built for GhostDriver, still based on the default WebDriver Atoms
#


usage() {
    echo ""
    echo "Usage:"
    echo "    export_ghostdriver.sh <PATH_TO_PHANTOMJS_REPO>"
    echo ""
}

info() {
    echo -e "\033[1;32m*** ${1}\033[0m"
}

if [[ $# < 1 ]]
then
    usage
    exit
fi

################################################################################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PHANTOMJS_REPO_PATH=$1
DESTINATION_PATH="${1}/src/ghostdriver"
DESTINATION_QRC_FILE="ghostdriver.qrc"
LASTUPDATE_FILE="${DESTINATION_PATH}/lastupdate"
GHOSTDRIVER_SOURCE_PATH="${SCRIPT_DIR}/../src"

#1. Delete the Destination Directory, if any
if [ -d $DESTINATION_PATH ]; then
    info "Deleting current GhostDriver exported in local PhantomJS source (path: '${DESTINATION_PATH}')"
    rm -rf $DESTINATION_PATH
fi

#2. Create the Destination Directory again
info "Creating directory to export GhostDriver into local PhantomJS source (path: '${DESTINATION_PATH}')"
mkdir -p $DESTINATION_PATH

#3. Copy all the content of the SOURCE_DIR in there
info "Copying GhostDriver over ('${GHOSTDRIVER_SOURCE_PATH}/*' => '${DESTINATION_PATH}')"
cp -r $GHOSTDRIVER_SOURCE_PATH/* $DESTINATION_PATH

#4. Generate the .qrc file
info "Generating Qt Resource File to import GhostDriver into local PhantomJS (path: '${DESTINATION_PATH}/${DESTINATION_QRC_FILE}')"

pushd $DESTINATION_PATH

# Initiate the .qrc destination file
echo "<RCC>" > $DESTINATION_QRC_FILE
echo "    <qresource prefix=\"ghostdriver/\">" >> $DESTINATION_QRC_FILE

for FILE in `find . -type f | sed "s/.\///"`
do
    if [[ $FILE != "." && $FILE != *.qrc ]]; then
        echo "        <file>${FILE}</file>" >> $DESTINATION_QRC_FILE
    fi
done

# Finish the .qrc destination file
echo "    </qresource>" >> $DESTINATION_QRC_FILE
echo "</RCC>" >> $DESTINATION_QRC_FILE

popd

#5. Record the Timestamp and Git repo hash to the "lastupdate" file
date +"%Y-%m-%d %H:%M:%S" > $LASTUPDATE_FILE
echo "" >> $LASTUPDATE_FILE
git log -n 1 >> $LASTUPDATE_FILE

info "DONE!"

