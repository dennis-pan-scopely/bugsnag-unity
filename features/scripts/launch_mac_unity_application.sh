#!/bin/sh -ex

pushd "${0%/*}"
  pushd ../fixtures
    mazerunner.app/Contents/MacOS/mazerunner -batchmode -nographics
  popd
popd
