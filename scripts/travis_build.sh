#!/bin/sh -ue

brew tap caskroom/cask
brew cask install android-sdk

yes | sdkmanager "platforms;android-27"
yes | sdkmanager --licenses

unity_url="https://download.unity3d.com/download_unity/21ae32b5a9cb/MacEditorInstaller/Unity-2017.4.3f1.pkg"
mono_url="https://download.mono-project.com/archive/5.12.0/macos-10-universal/MonoFramework-MDK-5.12.0.226.macos10.xamarin.universal.pkg"

curl -o Mono.pkg $mono_url & curl -o Unity.pkg $unity_url & wait

sudo installer -dumplog -package Mono.pkg -target /

export PATH="$PATH:/Library/Frameworks/Mono.framework/Versions/Current/Commands"

sudo installer -dumplog -package Unity.pkg -target /

bundle install

# activate Unity
"/Applications/Unity/Unity.app/Contents/MacOS/Unity -quit -batchmode -serial $UNITY_SERIAL -username $UNITY_USERNAME -password $UNITY_PASSWORD -logFile unity.log"
# usage suggests that sometimes this can take longer than the command so wait for the above command to take effect
sleep 10

# turn off errexit here as we need to return the unity license even if these commands fail
set +e

# build the plugin
bundle exec rake plugin:export
exit_status=$?

# copy it to the directory that is being synchronised with S3
cp Bugsnag.unitypackage ~/$TRAVIS_BUILD_NUMBER

set -e

# return the Unity license as we can only have two simultaneous activations of each license
"/Applications/Unity/Unity.app/Contents/MacOS/Unity -quit -batchmode -returnlicense -logFile unity.log"
# usage suggests that sometimes this can take longer than the command so wait for the above command to take effect
sleep 10

exit $exit_status
