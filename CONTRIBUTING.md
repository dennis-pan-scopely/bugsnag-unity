
# Contributing

- [Fork](https://help.github.com/articles/fork-a-repo) the [notifier on github](https://github.com/bugsnag/bugsnag-android)
- Build and test your changes
- Commit and push until you are happy with your contribution
- [Make a pull request](https://help.github.com/articles/using-pull-requests)
- Thanks!

## Set up a development environment

- Clone the repo including submodules

    ```
    git clone --recursive git@github.com:bugsnag/bugsnag-unity
    ```

- Set up your Xcode (requires being a member of the Apple Developer Program)
- Set up the Android SDK (using [instructions](https://github.com/bugsnag/bugsnag-android/blob/master/CONTRIBUTING.md) from bugsnag-android)
- Open the example app in Unity
- You can build the app for iPhone or Android using the custom Build menu.

## Testing Changes
A simple project can be found at [examples/Assets/Buttons.unity](https://github.com/bugsnag/bugsnag-unity/blob/master/example/Assets/Buttons.unity), which allows various crashes to be triggered by clicking buttons.

## Upgrading bugsnag-cocoa/bugsnag-android

- Update the submodule

    ```
    cd bugsnag-cocoa; git pull origin unity; cd ..
    cd bugsnag-android; git pull origin master; cd ..
    cd ..; git commit -am "updating notifiers"
    ```

- Update the plugins in the example app

    ```
    rake update_example_plugins
    ```

- Build and test the example app

    ```
    rake build:ios
    rake build:android
    ```

## Modifying the C# code

- Make changes to src/Assets
- Copy changes into the example app

    ```
    rake update
    ```

- Build and test the example app

    ```
    rake build:ios
    rake build:android
    ```


## Releasing a new version

### Release Checklist

#### Pre-release

- [ ] Are all changes committed?
- [ ] Does the build pass on the CI server?
- [ ] Has the changelog been updated?
- [ ] Have all the version numbers been incremented? Update the version number by running `make VERSION=[number] bump`.
- [ ] Has all new functionality been manually tested on a release build? Use `rake build` to generate an artifact to install in a new app.
  - [ ] Is development mode disabled? Disable development mode in the Unity Build dialog when testing release builds.
  - [ ] Test that a log message formatted as `SomeTitle: rest of message` generates an error titled `SomeTitle` with message `rest of message`
  - [ ] Test that a log message formatted without a colon generates an error titled `LogError<level>` with message `rest of message`
  - [ ] Ensure the example app sends the correct error for each type on iOS
  - [ ] Ensure the example app sends the correct error for each type on tvOS
  - [ ] Ensure the example app sends the correct error for each type on macOS
  - [ ] Ensure the example app sends the correct error for each type on Android
  - [ ] Ensure the example app sends the correct error for each type on WebGL
  - [ ] Archive the iOS app and validate the bundle type
  - [ ] Generate a signed APK for Android
- [ ] Do the installation instructions work when creating an example app from scratch?
- [ ] Are PRs open on the docs site for any new feature changes or version numbers?
- [ ] Have the installation instructions been updated on the [dashboard](https://github.com/bugsnag/bugsnag-website/tree/master/app/views/dashboard/projects/install)
- [ ] Have the installation instructions been updated on the [docs site](https://github.com/bugsnag/docs.bugsnag.com)?


#### Making the release

1. Commit the changelog and version updates:

    ```
    git add CHANGELOG.md src/BugsnagUnity.mm bugsnag-android-unity/src/main/java/com/bugsnag/android/unity/UnityCallback.java
    git commit -m "Release v3.x.x"
    git tag "v3.x.x"
    git push origin master --tags
    ```
2. [Create a new release on GitHub](https://github.com/bugsnag/bugsnag-unity/releases/new), copying the changelog entry.
    * set the title to the tag name
    * upload `Bugsnag.unitypackage`

#### Post-release

- [ ] Have all Docs PRs been merged?
- [ ] Can the latest release be installed by downloading the artifact from the releases page?
- [ ] Do the installation instructions on the dashboard work using the released artefact?
- [ ] Do the installation instructions on the docs site work using the released artefact?
- [ ] Can a freshly created example app send an error report from a release build, using the released artefact?
- [ ] Do the existing example apps send an error report using the released artefact?
