#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# Script for automatic updating spring-configuration-metadata.json files used for rendering Nixer properties documentatnion.
# Uses results of nixer-spring-plugin project build execution, i.e. generated JARs, as sources for the update.
# Copies the metadata from the source JARs to the metadata files in this documentation codebase,
# effectively updating them or leaving intact if no difference.
#
# All changes are done locally and need to be commited.

NIXER_PLUGIN_PREFIX="nixer-plugin"

NIXER_CODEBASE_DIR=${1:-}

if [[ -z ${NIXER_CODEBASE_DIR} ]]; then
  echo "Missing mandatory argument: nixer-spring-plugin codebase directory."
  exit 1
fi

if [[ ! -d ${NIXER_CODEBASE_DIR} ]]; then
  echo "nixer-spring-plugin codebase directory '${NIXER_CODEBASE_DIR}' does not exist."
  exit 1
fi

if [ -n "$(git status --untracked-files=no --porcelain)" ]; then
  echo "Working directory is not clean. Please commit or stash any changes and try again."
  exit 1
fi

echo ""
echo "==> Updating Nixer properties metadata using nixer-spring-plugin codebase: ${NIXER_CODEBASE_DIR}"
echo ""

for module in "captcha" "core" "pwned-check" "stigma"
do
  echo "---> Updating metadata for module: ${module}"

  BUILD_DIR=${NIXER_CODEBASE_DIR}/${module}/build/libs

  if [[ ! -d ${BUILD_DIR} ]]; then
    echo "Build directory '${BUILD_DIR}' does not exist. Was build of nixer-spring-plugin executed?"
    exit 1
  fi

  SOURCE_JAR_PATH=$(find "${NIXER_CODEBASE_DIR}/${module}/build/libs" -type f -name "${NIXER_PLUGIN_PREFIX}-${module}*.jar")

  if [[ ! -f ${SOURCE_JAR_PATH} ]]; then
    echo "Source JAR not found. Was build of nixer-spring-plugin executed?"
    exit 1
  fi

  echo ""
  echo "  -> Using source:  $(basename "${SOURCE_JAR_PATH}")"
  echo ""

  unzip -p "${SOURCE_JAR_PATH}" META-INF/spring-configuration-metadata.json > "_data/nixer-props-metadata/${module}/spring-configuration-metadata.json"

  echo "  -> ${module} metadata updated:"
  echo "       _data/nixer-props-metadata/${module}/spring-configuration-metadata.json"
  echo ""
  echo ""

done

echo "==> Updating Nixer properties metadata done. Please verify changes and commit."
echo ""
