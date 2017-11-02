#!/usr/bin/env bash

#############################################################################
# To use this script, make sure you have "if: tag IS empty" in your .travis.yml file or your build will
# go into an infinite loop!!!   https://github.com/travis-ci/travis-ci/issues/8051
#
# Define MY_REPO to be your github URL minus the https and the token, defaults to
#     https://${GH_TOKEN}@github.com/rerun-modules/MODULENAME
#
# Securely define GH_TOKEN to be your github access token in your .travis.yml 
#     https://docs.travis-ci.com/user/environment-variables/#Defining-encrypted-variables-in-.travis.yml
#############################################################################

# Fail fast on errors and unset variables.
set -eu

# Prepare.
# --------
# set version patch number to build number from travis
sed -i -r 's,^VERSION=([0-9]+\.[0-9]+)\.0$,VERSION=\1.'"${TRAVIS_BUILD_NUMBER:?SetupTravisCorrectly}"',g' metadata
VERSION="$(awk -F= '/VERSION/ {print $2}' metadata)"
description="$(awk -F= '/DESCRIPTION/ {print $2}' metadata)"
license="$(awk -F= '/LICENSE/ {print $2}' metadata)"
export VERSION
mymod="$(awk -F= '/NAME/ {print $2}' metadata)"
GITREPO="https://${GH_TOKEN}@${MY_REPO:=github.com/rerun-modules/${mymod}}"

echo "Building version ${VERSION:?"Corrupt metadata file"} of ${mymod:?"Corrupt metadata file"}..."
# Create a scratch directory and change directory to it.
WORK_DIR=$(mktemp -d "/tmp/build-${mymod}.XXXXXX")
mkdir "${WORK_DIR:?'Unable to create temp dir'}/${mymod}"

git clone "file://${TRAVIS_BUILD_DIR:?SetupTravisCorrectly}" "${WORK_DIR}/${mymod}"
cp -p metadata "${WORK_DIR}/${mymod}"/
# Bootstrap
# ---------

# Setup the rerun execution environment.
export RERUN_MODULES="${WORK_DIR}:${RERUN_MODULES:-/usr/lib/rerun/modules}"

# Test.
# --------
[[ "${TRAVISCI_SKIP_TESTS:-}" != "true" ]] && rerun stubbs: test --module "${mymod}"

# Build the module.
# -----------------
echo "Packaging the build..."

# Build the archive!
rerun stubbs:archive --modules "${mymod}"
BIN="rerun.sh"
[ ! -f "${BIN}" ] && {
    echo >&2 "ERROR: ${BIN} archive was not created."; exit 1
}

# Test the archive by making it do a command list.
./${BIN} "${mymod}"

# Build a deb
#-------------
rerun stubbs:archive --modules "${mymod}" --format deb --version "${VERSION}" --release "${RELEASE:=1}"
sysver="${VERSION}-${RELEASE}"
DEB="rerun-${mymod}_${sysver}_all.deb"
[ ! -f "${DEB}" ] && {
    echo >&2 "ERROR: ${DEB} file was not created."
    files=( *.deb )
    echo >&2 "ERROR: ${#files[*]} files matching .deb: ${files[*]}"
    exit 1
}
# Build a rpm
#-------------
rerun stubbs:archive --modules "${mymod}" --format rpm --version "${VERSION}" --release "${RELEASE}"
RPM=rerun-${mymod}-${sysver}.linux.noarch.rpm
[ ! -f "${RPM}" ] && {
    echo >&2 "ERROR: ${RPM} file was not created."
    files=( *.rpm )
    echo >&2 "ERROR: ${#files[*]} files matching .rpm: ${files[*]}"
    exit 1
}

if [[ "${TRAVIS_BRANCH}" == "master" && "${TRAVIS_PULL_REQUEST}" == "false" ]]; then

####  Upstream bug in bintray, can't lable repo w/o error!!  -->   "github_repo": "${MY_REPO#*/}",
####  May be redundant as vcs_url is all that is needed https://stackoverflow.com/questions/43694831

  export DESCRIPTOR=/tmp/descriptor.txt
  cat <<-EOF > "${DESCRIPTOR}"
	{
	  "name": "${mymod}",
	  "desc": ${description},
	  "labels": [ "shell", "bash", "rerun", "rerun-modules" ],
	  "licenses": ${license},
	  "vcs_url": "https://${MY_REPO}.git",
	  "website_url": "https://${MY_REPO}",
	  "issue_tracker_url": "https://${MY_REPO}/issues",
	  "public_download_numbers": "false",
	  "public_stats": "false"
	}
EOF
  echo ${DESCRIPTOR}
  cat ${DESCRIPTOR}
  echo

  echo "Tagging version in git"
  git checkout metadata
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
  git tag -a "v${VERSION}" -m "skip ci - Travis CI release v${VERSION}"
  echo "Pushing tag v${VERSION}"
  git push --quiet "${GITREPO}" --tags > /dev/null 2>&1

  echo "Files to publish"
  ls -1 rerun.sh "rerun-${mymod}"*

  export USER=${BINTRAY_USER:?"Setup Travis with BINTRAY_USER env variable"}
  export APIKEY=${BINTRAY_APIKEY:?"Setup Travis with BINTRAY_APIKEY env variable"}
  export ORG=${BINTRAY_ORG:?"Setup Travis with BINTRAY_ORG env variable"}
  export PACKAGE="${mymod}"
  
  # Upload and publish to bintray
  echo "Uploading ${BIN} to bintray: /${BINTRAY_ORG}/rerun-modules/${mymod}/${VERSION}..."
  export REPO="rerun-modules"
  rerun bintray:package-upload --file "${BIN}"

  echo "Uploading debian package ${DEB} to bintray: /${BINTRAY_ORG}/rerun-deb ..."
  export PACKAGE="rerun-${mymod}"
  export REPO="rerun-deb"
  rerun bintray:package-upload-deb --version "${sysver}" --file "${DEB}" --deb_architecture all
  rerun bintray:package-upload --version "${sysver}" --file "${PACKAGE}_${VERSION}.orig.tar.gz"
  rerun bintray:package-upload --version "${sysver}" --file "${PACKAGE}_${sysver}.debian.tar.gz"
  rerun bintray:package-upload --version "${sysver}" --file "${PACKAGE}_${sysver}_amd64.build"
  rerun bintray:package-upload --version "${sysver}" --file "${PACKAGE}_${sysver}_amd64.changes"
  rerun bintray:package-upload --version "${sysver}" --file "${PACKAGE}_${sysver}.dsc"

  echo "Uploading rpm package ${RPM} to bintray: /${BINTRAY_ORG}/rerun-rpm ..."
  export REPO="rerun-rpm"
  rerun bintray:package-upload --version "${sysver}" --file "${RPM}"

  rm ${DESCRIPTOR}

else
  echo "***************************"
  echo "***                     ***"
  echo "*** Travis-CI sayz LGTM ***"
  echo "***                     ***"
  echo "***************************"
fi


echo "Done."
