---
name: iphone-install
description: Builds the Tellbow iOS app (app/) in release mode and installs it on the user's iPhone over Wi-Fi, including the fallback when Flutter's install or launch step fails; runs on Haiku in a forked subagent and reports whether the app is on the phone. The phone must be unlocked and on the same Wi-Fi. Use when the user wants the new app on their phone.
context: fork
model: haiku
background: false
---

# Install the app on the iPhone

You run without the conversation that asked for this, and you cannot ask
the user anything: do the steps, then report.

The iPhone («Wodan») was paired by cable once and is reachable over Wi-Fi.
It uses a free Apple ID: an installed app stops starting after 7 days, and
installing again renews it. The app downloads its data from the newest
GitHub release on first launch; an update keeps the data it has.

1. `cd app && flutter devices` lists «Wodan (wireless)» with its id. If it
   is missing, stop and report that: the phone must be unlocked and on the
   same Wi-Fi.
2. `flutter run --release --no-resident -d <id>` builds (about a minute),
   installs and starts the app.
3. If it ends with «Could not run build/ios/iphoneos/Runner.app»: the build is
   there, install it directly:
   `xcrun devicectl device install app --device <id> build/ios/iphoneos/Runner.app`,
   then start it:
   `xcrun devicectl device process launch --device <id> ch.tellbow.schwingen`.
   «Device is busy (Connecting to Wodan)» or «disconnected immediately»
   mean the phone is locked or asleep: stop and report that. Do not build
   again; the next try needs only these two commands.
4. Signing: the project signs with the team in `DEVELOPMENT_TEAM`
   (`ios/Runner.xcodeproj/project.pbxproj`), the Apple ID in Xcode
   (Settings → Accounts). If `security find-identity -v -p codesigning`
   finds no valid identity, Apple's WWDR G3 intermediate certificate is
   missing from the keychain
   (https://www.apple.com/certificateauthority/AppleWWDRCAG3.cer): report
   that, do not change the keychain.
   «No Accounts» means the shell cannot reach the keychain: run the build
   outside the sandbox. «No profiles for 'ch.tellbow.schwingen' were
   found» means Xcode has not made the app's profile yet, which only the
   Xcode app does: report that the user must open
   `app/ios/Runner.xcworkspace`, check Runner → Signing & Capabilities
   (team set, automatic signing on) and build once (⌘B) with Wodan
   selected. Do not change the project or try to sign in.

Answer in a few lines: the commit installed (`git describe --tags --always`),
whether it is installed and started, or the step that failed with its error
message. If the phone was locked, say so first: the user must unlock it and
ask again, or open the app by hand when only the start failed.
