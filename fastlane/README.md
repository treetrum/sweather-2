fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios createconfig
```
fastlane ios createconfig
```
Creates the config.xcconfig file required for building the app. Relies on the .env file existing in the project root. Check your 1password for this file.
### ios beta
```
fastlane ios beta
```
Push a new beta build to TestFlight
### ios screenshots
```
fastlane ios screenshots
```
Automatically creates screenshots throughtout the app
### ios deliver_screenshots
```
fastlane ios deliver_screenshots
```
Uploads screenshots for a given version to appstore connect
### ios deliver_metadata
```
fastlane ios deliver_metadata
```
Uploads metadata to appstore connect
### ios deliver_screenshots_and_metadata
```
fastlane ios deliver_screenshots_and_metadata
```
Uploads screenshots & metadata to appstore connect
### ios certificates
```
fastlane ios certificates
```
Switches to development certificates
### ios bump_and_commit
```
fastlane ios bump_and_commit
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
