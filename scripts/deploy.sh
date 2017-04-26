#!/bin/bash

# variables
BUILD_FOLDER="public"
TARGET_BRANCH="master"
GITHUB_REPO="@github.com/weihanchen/weihanchen.github.io.git"
FULL_REPO="https://${GITHUB_TOKEN}${GITHUB_REPO}"


# config/deploy
cd $BUILD_FOLDER
git init
git config --global user.email "${GITHUB_MAIL}"
git config --global user.name "${GITHUB_USER}"
git add .
MESSAGE=`date +\ %Y-%m-%d\ %H:%M:%S`
git commit -m "Site updated:${MESSAGE}"
git push --force "https://${GITHUB_TOKEN}${GITHUB_REPO}" $TARGET_BRANCH:$TARGET_BRANCH
