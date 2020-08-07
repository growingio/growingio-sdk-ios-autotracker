#!/bin/sh
security delete-keychain ios-build.keychain
rm -f ~/Library/MobileDevice/Provisioning\ Profiles/$PROFILE_NAME.mobileprovision
rm -f ~/Library/MobileDevice/Provisioning\ Profiles/team.mobileprovision
