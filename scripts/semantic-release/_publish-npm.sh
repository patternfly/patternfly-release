#!/bin/sh

default()
{
  # Add paths to env (non-Travis build)
  if [ -z "$TRAVIS" ]; then
    PATH=/usr/local/bin:/usr/bin:/bin:$PATH
    export PATH
  fi

  SCRIPT=`basename $0`
  SCRIPT_DIR=`dirname $0`
  SCRIPT_DIR=`cd $SCRIPT_DIR; pwd`

  . $SCRIPT_DIR/../_env.sh
  . $SCRIPT_DIR/../_common.sh
  . $SCRIPT_DIR/_common.sh

  BUILD_DIR=$TRAVIS_BUILD_DIR
}

# Check prerequisites before continuing
#
prereqs()
{
  merge_prereqs

  if [ ! -s "$BOWER_JSON" ]; then
    return
  fi

  # Get version generated by 'semantic-release pre'
  VERSION=`grep '"version"' $PACKAGE_JSON | \
    awk -F':' '{print $2}' | \
    sed 's|\"||g' | \
    sed 's|,||g' | \
    sed 's| *||g'`

  BOWER_VERSION=`grep '"version"' $BOWER_JSON | \
    awk -F':' '{print $2}' | \
    sed 's|\"||g' | \
    sed 's|,||g' | \
    sed 's| *||g'`

  if [ "$VERSION" != "$BOWER_VERSION" ]; then
    echo "*** The $PACKAGE_JSON and $BOWER_JSON versions differ. Do not publish!"
    exit 1
  fi
}

# Publish npm
#
# $1 directory to publish
publish_npm()
{
  echo "*** Publishing npm"
  cd $BUILD_DIR

  if [ -f "$SKIP_NPM_PUBLISH" ]; then
    echo "*** Found $SKIP_NPM_PUBLISH file indicator. Do not publish!"
    exit 1
  fi

  npm publish $1
  check $? "npm publish failure"
}


# Publish npm from dist directory
#
publish_npm_dist() {
  echo "*** Copying files to dist"
  cd $BUILD_DIR

  cp -r $GIT_DIR $DIST_DIR
  check $? "Copy $GIT_DIR failure"

  cp $PACKAGE_JSON $DIST_DIR
  check $? "Copy $PACKAGE_JSON failure"

  cp $SHRINKWRAP_JSON $DIST_DIR
  check $? "Copy $SHRINKWRAP_JSON failure"
  
  publish_npm $DIST_DIR
}

usage()
{
cat <<- EEOOFF

    This script runs 'npm publish' from the root or $DIST_DIR directory. If $BOWER_JSON exists, the version in
    $PACKAGE_JSON must match or the script exists with an error.

    In addition to running 'npm publish', the -d switch will copy $PACKAGE_JSON, $SHRINKWRAP_JSON, and the $GIT_DIR
    directory to $DIST_DIR.

    Note:

    sh [-x] $SCRIPT [-h|d]

    Example: sh $SCRIPT -d

    OPTIONS:
    h       Display this message (default)
    d       Publish $DIST directory

EEOOFF
}

# main()
{
  default

  while getopts hd c; do
    case $c in
      h) usage; exit 0;;
      d) PUBLISH_DIST=1;;
      \?) usage; exit 1;;
    esac
  done

  prereqs

  if [ -n "$PUBLISH_DIST" ]; then
    publish_npm_dist
  else
    publish_npm
  fi
}
