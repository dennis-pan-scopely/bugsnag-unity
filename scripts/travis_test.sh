#!/bin/sh -ue

curl -o Unity.pkg $UNITY_URL
sudo installer -dumplog -package Unity.pkg -target /

# copy the package to the root

if [[ -z "${ANDROID_TARGET}" ]]; then
  yes | sdkmanager "platforms;$ANDROID_TARGET"
  android list targets
  jdk_switcher use oraclejdk8
  echo no | android create avd --force -n nexus -t $ANDROID_TARGET --abi $ANDROID_ABI
  bundle exec rake travis:mazerunner\[android\]
else
  bundle exec rake travis:mazerunner\[macos\]
fi
