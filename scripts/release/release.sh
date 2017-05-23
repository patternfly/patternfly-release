#!/usr/bin/env bash

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

  BRANCH=$RELEASE_BRANCH
  BRANCH_DIST=$RELEASE_DIST_BRANCH
  TMP_DIR="/tmp/patternfly-releases"
}

# Bump version number in bower.json
#
bump_bower()
{
  echo "*** Bumping version in $BOWER_JSON to $VERSION"
  cd $BUILD_DIR

  if [ ! -s "$BOWER_JSON" ]; then
    return
  fi

  # For testing forks without npm publish, set REPO_FORK=1 via local env
  if [ -n "$REPO_FORK" ]; then
    PKG_PTNFLY="git://$REPO_URL_PTNFLY#$BRANCH_DIST"
    PKG_PTNFLY_ANGULAR="git://$REPO_URL_PTNFLY_ANGULAR#$BRANCH_DIST"
  else
    PKG_PTNFLY=~$VERSION
    PKG_PTNFLY_ANGULAR=~$VERSION
  fi

  if [ -n "$PTNFLY" ]; then
    sed "s|\"version\":.*|\"version\": \"$VERSION\",|" $BOWER_JSON > $BOWER_JSON.tmp
  elif [ -n "$PTNFLY_ANGULAR" ]; then
    sed "s|\"version\":.*|\"version\": \"$VERSION\",|" $BOWER_JSON | \
    sed "s|\"patternfly\":.*|\"patternfly\": \"$PKG_PTNFLY\"|" > $BOWER_JSON.tmp
  elif [ -n "$PTNFLY_NG" ]; then
    sed "s|\"version\":.*|\"version\": \"$VERSION\",|" $BOWER_JSON | \
    sed "s|\"patternfly\":.*|\"patternfly\": \"$PKG_PTNFLY\"|" > $BOWER_JSON.tmp
  elif [ -n "$PTNFLY_ORG" ]; then
    sed "s|\"version\":.*|\"version\": \"$VERSION\",|" $BOWER_JSON | \
    sed "s|\"patternfly\":.*|\"patternfly\": \"$PKG_PTNFLY\",|" | \
    sed "s|\"angular-patternfly\":.*|\"angular-patternfly\": \"$PKG_PTNFLY_ANGULAR\",|" > $BOWER_JSON.tmp
  elif [ -n "$RCUE" ]; then
    sed "s|\"version\":.*|\"version\": \"$VERSION\",|" $BOWER_JSON | \
    sed "s|\"patternfly\":.*|\"patternfly\": \"$PKG_PTNFLY\"|" > $BOWER_JSON.tmp
  fi
  check $? "Version bump failure"

  if [ -s "$BOWER_JSON.tmp" ]; then
    mv $BOWER_JSON.tmp $BOWER_JSON
    check $? "File move failure"
  fi
}

# Bump version number in package.json
#
bump_package()
{
  echo "*** Bumping version in $PACKAGE_JSON to $VERSION"
  cd $BUILD_DIR

  # For testing forks without npm publish, set REPO_FORK=1 via local env
  if [ -n "$REPO_FORK" ]; then
    PKG_PTNFLY="git+https://$REPO_URL_PTNFLY#$BRANCH_DIST"
    PKG_PTNFLY_ENG_RELEASE="git+https://$REPO_URL_PTNFLY_ENG_RELEASE"
  else
    PKG_PTNFLY=~$VERSION
    PKG_PTNFLY_ENG_RELEASE=~$VERSION
  fi

  if [ -n "$PTNFLY" ]; then
    sed "s|\"version\":.*|\"version\": \"$VERSION\",|" $PACKAGE_JSON | \
    sed "s|\"patternfly-eng-release\":.*|\"patternfly-eng-release\": \"$PKG_PTNFLY_ENG_RELEASE\",|" > $PACKAGE_JSON.tmp
  elif [ -n "$PTNFLY_ANGULAR" ]; then
    sed "s|\"version\":.*|\"version\": \"$VERSION\",|" $PACKAGE_JSON | \
    sed "s|\"patternfly\":.*|\"patternfly\": \"$PKG_PTNFLY\"|" | \
    sed "s|\"patternfly-eng-release\":.*|\"patternfly-eng-release\": \"$PKG_PTNFLY_ENG_RELEASE\"|" > $PACKAGE_JSON.tmp
  elif [ -n "$PTNFLY_NG" ]; then
    sed "s|\"version\":.*|\"version\": \"$VERSION\",|" $PACKAGE_JSON | \
    sed "s|\"patternfly\":.*|\"patternfly\": \"$PKG_PTNFLY\"|" | \
    sed "s|\"patternfly-eng-release\":.*|\"patternfly-eng-release\": \"$PKG_PTNFLY_ENG_RELEASE\"|" > $PACKAGE_JSON.tmp
  elif [ -n "$PTNFLY_ORG" ]; then
    sed "s|\"version\":.*|\"version\": \"$VERSION\",|" $PACKAGE_JSON | \
    sed "s|\"patternfly-eng-release\":.*|\"patternfly-eng-release\": \"$PKG_PTNFLY_ENG_RELEASE\",|" > $PACKAGE_JSON.tmp
  elif [ -n "$RCUE" ]; then
    sed "s|\"version\":.*|\"version\": \"$VERSION\",|" $PACKAGE_JSON | \
    sed "s|\"patternfly\":.*|\"patternfly\": \"$PKG_PTNFLY\"|" | \
    sed "s|\"patternfly-eng-release\":.*|\"patternfly-eng-release\": \"$PKG_PTNFLY_ENG_RELEASE\"|" > $PACKAGE_JSON.tmp
  elif [ -n "$PTNFLY_ENG_RELEASE" ]; then
    sed "s|\"version\":.*|\"version\": \"$VERSION\",|" $PACKAGE_JSON > $PACKAGE_JSON.tmp
  elif [ -n "$PTNFLY_WC" ]; then
    sed "s|\"version\":.*|\"version\": \"$VERSION\",|" $PACKAGE_JSON > $PACKAGE_JSON.tmp
  fi
  check $? "Version bump failure"

  if [ -s "$PACKAGE_JSON.tmp" ]; then
    mv $PACKAGE_JSON.tmp $PACKAGE_JSON
    check $? "File move failure"
  fi
}

# Bump version in home page
#
bump_home()
{
  echo "*** Bumping version in $HOME_HTML to $VERSION"
  cd $BUILD_DIR

  if [ -n "$PTNFLY_ORG" ]; then
    PREFIX="<p class=\"version wow fadeIn\" data-wow-delay=\"1500ms\">Version"
    sed "s|$PREFIX.*|$PREFIX $VERSION</p>|" $HOME_HTML > $HOME_HTML.tmp
    check $? "Version bump failure"
  fi
  if [ -s "$HOME_HTML.tmp" ]; then
    mv $HOME_HTML.tmp $HOME_HTML
    check $? "File move failure"
  fi
}

# Bump version number in JavaScript
#
bump_js()
{
  echo "*** Bumping version in $PTNFLY_SETTINGS_JS to $VERSION"
  cd $BUILD_DIR

  if [ -n "$PTNFLY" ]; then
    sed "s|version:.*|version: \"$VERSION\",|" $PTNFLY_SETTINGS_JS > $PTNFLY_SETTINGS_JS.tmp
  fi
  check $? "Version bump failure"

  if [ -s "$PTNFLY_SETTINGS_JS.tmp" ]; then
    mv $PTNFLY_SETTINGS_JS.tmp $PTNFLY_SETTINGS_JS
    check $? "File move failure"
  fi
}

# Clean cache
#
clean_cache()
{
  echo "*** Cleaning npm and bower cache"
  cd $BUILD_DIR

  # Clean npm and bower installs
  npm cache clean
  bower cache clean
}

# Clean shrinkwrap
#
clean_shrinkwrap()
{
  if [ -s $SHRINKWRAP_JSON ]; then
    rm -f $SHRINKWRAP_JSON
  fi
}

# Commit changes prior to bower verify step
#
commit()
{
  echo "*** Committing changes"
  cd $BUILD_DIR

  git add -u
  git commit -m "Bumped version number to $VERSION"
}

# Push changes to remote repo
#
# $1: Branch name
push()
{
  echo "*** Pushing changes to $REPO_SLUG"
  cd $BUILD_DIR

  git checkout -B $1
  git push --set-upstream origin $1 --force
  check $? "git push failure"

  echo "*** Changes pushed to the $1 branch of $REPO_SLUG"
  echo "*** Review changes and create a PR via GitHub"
}

# Shrink wrap npm and run vulnerability test
#
shrinkwrap()
{
  echo "*** Shrink wrapping $SHRINKWRAP_JSON"
  cd $BUILD_DIR

  # Only include production dependencies with shrinkwrap
  npm prune --production

  npm shrinkwrap
  check $? "npm shrinkwrap failure"

  # Restore all packages for testing with karma, nsp, etc.
  npm install
}

usage()
{
cat <<- EEOOFF

    This script will bump repo version numbers, build, shrinkwrap, test, install, push to GitHub.

    Note: After changes are pushed, a PR will need to be created via GitHub.

    sh [-x] $SCRIPT [-h|b|f|g|n|s] -a|e|o|p|r|w|x -v <version>

    Example: sh $SCRIPT -v 3.15.0 -p

    OPTIONS:
    h       Display this message (default)
    a       Angular PatternFly
    e       PatternFly Eng Release
    o       PatternFly Org
    p       PatternFly
    r       RCUE
    v       The version number (e.g., 3.15.0)
    w       PatternFly Web Components
    x       Patternfly NG

    SPECIAL OPTIONS:
    b       The branch to release (e.g., $NEXT_BRANCH)
    f       Run against repo fork matching local username (e.g., `whoami`/patternfly)
    g       Push new branch to GitHub (e.g., bump-v3.15.0)
    n       Release PF 'next' branches (e.g., PF4 alpha, beta, etc.)
    s       Skip new clone and clean cache (e.g., to rebuild existing repo)

EEOOFF
}

# Verify npm and bower installs prior to publish step
#
# $1: Verify directory
# $2: Build directory
verify()
{
  echo "*** Verifying install"

  rm -rf $1
  mkdir -p $1
  cd $1

  if [ -s "$2/$PACKAGE_JSON" ]; then
    npm install $2
    check $? "npm install failure"

    if [ ! -d "$1"/node_modules ]; then
      check 1 "npm install failure: node_modules directory expected"
    fi
  fi
  if [ -s "$2/$BOWER_JSON" ]; then
    cp $2/$BOWER_JSON .
    bower install
    check $? "bower install failure"
  fi
}

# main()
{
  # Source env.sh afer setting REPO_FORK
  if [ -z "$TRAVIS" ]; then
    while getopts hab:efgnoprsv:w c; do
      case $c in
        f) REPO_FORK=1;;
        \?) ;;
      esac
    done
    unset OPTIND
  fi

  default

  if [ "$#" -eq 0 ]; then
    usage
    exit 1
  fi

  while getopts hab:efgnoprsv:wx c; do
    case $c in
      h) usage; exit 0;;
      a) PTNFLY_ANGULAR=1;
         BUILD_DIR=$TMP_DIR/angular-patternfly;
         REPO_SLUG=$REPO_SLUG_PTNFLY_ANGULAR;
         VERIFY_DIR="$TMP_DIR/angular-patternfly-verify";;
      b) BRANCH=$OPTARG;;
      e) PTNFLY_ENG_RELEASE=1;
         BUILD_DIR=$TMP_DIR/patternfly-eng-release;
         REPO_SLUG=$REPO_SLUG_PTNFLY_ENG_RELEASE;
         VERIFY_DIR="$TMP_DIR/patternfly-eng-release-verify";;
      f) ;;
      g) PUSH=1;;
      n) BRANCH_DIST=$NEXT_DIST_BRANCH;;
      o) PTNFLY_ORG=1;
         BUILD_DIR=$TMP_DIR/patternfly-org;
         REPO_SLUG=$REPO_SLUG_PTNFLY_ORG;
         VERIFY_DIR="$TMP_DIR/patternfly-org-verify";;
      p) PTNFLY=1;
         BUILD_DIR=$TMP_DIR/patternfly;
         REPO_SLUG=$REPO_SLUG_PTNFLY;
         VERIFY_DIR="$TMP_DIR/patternfly-verify";;
      r) RCUE=1;
         BUILD_DIR=$TMP_DIR/rcue;
         REPO_SLUG=$REPO_SLUG_RCUE;
         VERIFY_DIR="$TMP_DIR/rcue-verify";;
      s) SKIP_SETUP=1;;
      v) VERSION=$OPTARG;
         BUMP_BRANCH=bump-v$VERSION;;
      w) PTNFLY_WC=1;
         BUILD_DIR=$TMP_DIR/patternfly-webcomponents;
         REPO_SLUG=$REPO_SLUG_PTNFLY_WC;
         VERIFY_DIR="$TMP_DIR/patternfly-webcomponents-verify";;
      x) PTNFLY_NG=1;
         BUILD_DIR=$TMP_DIR/patternfly-ng;
         REPO_SLUG=$REPO_SLUG_PTNFLY_NG;
         VERIFY_DIR="$TMP_DIR/patternfly-ng";;
      \?) usage; exit 1;;
    esac
  done

  if [ -z "$VERSION" -o -z "$REPO_SLUG" ]; then
    usage
    exit 1
  fi

  # Release from the latest repo clone or Travis build
  if [ -n "$TRAVIS_BUILD_DIR" ]; then
    BUILD_DIR=$TRAVIS_BUILD_DIR
  fi
  if [ -z "$SKIP_SETUP" ]; then
    setup_repo $REPO_SLUG $BRANCH
    clean_cache
  fi

  clean_shrinkwrap # Remove shrinkwrap prior to install
  bump_bower
  bump_package
  bump_home
  bump_js
  build_install
  build

  if [ -n "$PTNFLY" -o -n "$PTNFLY_ANGULAR" -o -n "$RCUE" -o -n "$PTNFLY_WC" ]; then
    shrinkwrap
  fi

  build_test
  commit # Commit changes prior to bower verify step
  verify $VERIFY_DIR $BUILD_DIR

  # Push changes to remote branch
  if [ -n "$PUSH" ]; then
    push $BUMP_BRANCH
  fi
  if [ -z "$TRAVIS" ]; then
    echo "*** Run publish-npm.sh to publish npm after PR has been merged"
    echo "*** Remove $TMP_DIR directory manually after testing"
  fi
}
