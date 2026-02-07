#!/bin/sh
# ----------------------------------------------------------------------------
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Apache Maven Wrapper startup batch script, version 3.3.2
#
# Optional ENV vars
#   MVNW_REPOURL - repo url base for downloading maven distribution
#   MVNW_USERNAME/MVNW_PASSWORD - user and password for downloading maven
#   MVNW_VERBOSE - true: enable verbose log; others: silence the output
# ----------------------------------------------------------------------------

set -euf
[ "${MVNW_VERBOSE-}" != true ] || set -x

# OS specific support.
native_path() { printf %s\\n "$1"; }
case "$(uname)" in
CYGWIN* | MINGW*)
  [ -z "${JAVA_HOME-}" ] || JAVA_HOME="$(cygpath --unix "$JAVA_HOME")"
  native_path() { cygpath --path --windows "$1"; }
  ;;
esac

# set JAVA_HOME
if [ -n "${JAVA_HOME-}" ]; then
  if [ -x "$JAVA_HOME/jre/sh/java" ]; then
    JAVACMD="$JAVA_HOME/jre/sh/java"
  else
    JAVACMD="$JAVA_HOME/bin/java"
    if [ ! -x "$JAVACMD" ]; then
      echo "The JAVA_HOME environment variable is not defined correctly," >&2
      echo "this environment variable is needed to run this program." >&2
      exit 1
    fi
  fi
else
  JAVACMD="$(
    'set' +e
    'unset' -f command 2>/dev/null
    'command' -v java
  )" || :
  if [ ! -x "${JAVACMD-}" ]; then
    echo "The java command is not available in PATH or JAVA_HOME." >&2
    exit 1
  fi
fi

# hash://
MVNW_HOME="${XDG_DATA_HOME:-"${HOME}/.local/share"}/mvnw"
MVN_PROJECTBASEDIR="${0%/*}"
MAVEN_PROJECTBASEDIR="$(cd -- "${MVN_PROJECTBASEDIR:-.}" && pwd -P)"
export MAVEN_PROJECTBASEDIR

# parse distributionUrl from .mvn/wrapper/maven-wrapper.properties
distributionUrl="$(sed -n 's/^distributionUrl=//p' "${MAVEN_PROJECTBASEDIR}/.mvn/wrapper/maven-wrapper.properties" | tr -d '\r')"
distributionUrlName="${distributionUrl##*/}"
distributionUrlNameMain="${distributionUrlName%.zip}"

MAVEN_HOME="${MVNW_HOME}/${distributionUrlNameMain}"
if [ -d "$MAVEN_HOME" ]; then
  MVNW_VERBOSE=true exec "$MAVEN_HOME/bin/mvn" "$@" || :
fi

if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
  echo "Error: curl or wget is required to download Maven." >&2
  exit 1
fi

mkdir -p -- "$MVNW_HOME" || :
TMP_DOWNLOAD_DIR="$(mktemp -d)" || TMP_DOWNLOAD_DIR="$MVNW_HOME/tmp-$$"
mkdir -p -- "$TMP_DOWNLOAD_DIR" || :

cleanup() { rm -rf -- "$TMP_DOWNLOAD_DIR"; }
trap cleanup HUP INT TERM EXIT

mvnw_download() {
  [ "${MVNW_VERBOSE-}" != true ] || echo "Downloading $1" >&2
  if command -v curl >/dev/null 2>&1; then
    curl ${MVNW_USERNAME:+--user "${MVNW_USERNAME}:${MVNW_PASSWORD}"} -fsSL -o "$2" "$1" || return 1
  elif command -v wget >/dev/null 2>&1; then
    wget ${MVNW_USERNAME:+--user="${MVNW_USERNAME}" --password="${MVNW_PASSWORD}"} --quiet -O "$2" "$1" || return 1
  fi
}

mvnw_download "$distributionUrl" "$TMP_DOWNLOAD_DIR/$distributionUrlName" || {
  echo "Error: Failed to download $distributionUrl" >&2
  exit 1
}

if command -v unzip >/dev/null 2>&1; then
  unzip -q -o "$TMP_DOWNLOAD_DIR/$distributionUrlName" -d "$MVNW_HOME" || {
    echo "Error: Failed to extract $distributionUrlName" >&2
    exit 1
  }
elif command -v tar >/dev/null 2>&1; then
  tar xzf "$TMP_DOWNLOAD_DIR/$distributionUrlName" -C "$MVNW_HOME" || {
    echo "Error: Failed to extract $distributionUrlName" >&2
    exit 1
  }
else
  echo "Error: unzip or tar is required." >&2
  exit 1
fi

exec "$MAVEN_HOME/bin/mvn" "$@"
