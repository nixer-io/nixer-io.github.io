#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# Script for automatic updating spring-configuration-metadata.json files used for rendering Nixer properties documentatnion.
# Fetches the metadata from Nixer artefacts deployed to Maven Centaral repository (repo1.maven.org mirror used explicitly for simplicity)
# and copies it to the metadata files in this docs codebase, effectively updating them or leaving intact if no difference.
#
# All changes are done locally and need to be commited.

MVN_REPO_BASE_URL="https://repo1.maven.org/maven2/io/nixer"
NIXER_PLUGIN_PREFIX="nixer-plugin"

VERSION=${1:-}

if [[ -z ${VERSION} ]]; then
  echo "Missing mandatory Nixer release version argument, e.g. 0.1.2.3"
  exit 1
fi

if [ -n "$(git status --untracked-files=no --porcelain)" ]; then
  echo "Working directory is not clean. Please commit or stash any changes and try again."
  exit 1
fi

echo ""
echo "==> Updating Nixer properties metadata to version ${VERSION}"
echo ""

for module in "captcha" "core" "pwned-check" "stigma"
do
  echo "---> Updating metadata for module: ${module}"

  JAR_FILE_NAME=${NIXER_PLUGIN_PREFIX}-${module}-${VERSION}.jar

  # example url: https://repo1.maven.org/maven2/io/nixer/nixer-plugin-stigma/0.1.1.2/nixer-plugin-stigma-0.1.1.2.jar
  wget --quiet "${MVN_REPO_BASE_URL}/${NIXER_PLUGIN_PREFIX}-${module}/${VERSION}/${JAR_FILE_NAME}"

  unzip -p "${JAR_FILE_NAME}" META-INF/spring-configuration-metadata.json > "_data/nixer-props-metadata/${module}/spring-configuration-metadata.json"

  rm "${JAR_FILE_NAME}"

  echo "---> ${module} metadata updated:"
  echo "     _data/nixer-props-metadata/${module}/spring-configuration-metadata.json"
  echo ""

done

echo "==> Updating Nixer properties metadata done. Please verify changes and commit."
echo ""
