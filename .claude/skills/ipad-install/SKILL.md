---
name: ipad-install
description: Builds the Tellbow iOS app (app/) in release mode and installs it on the user's iPad over Wi-Fi (or cable), including the fallback when Flutter's install or launch step fails; runs on Haiku in a forked subagent and reports whether the app is on the iPad. The iPad must be paired once, unlocked and on the same Wi-Fi. Use when the user wants the new app on their iPad.
context: fork
model: haiku
background: false
---

# Install the app on the iPad

You run without the conversation that asked for this, and you cannot ask
the user anything: do the steps, then report.

The iPad («iPad von Wodan») is signed like the iPhone (the
`iphone-install` skill). The app downloads its data from the newest
GitHub release on first launch; an update keeps the data it has.

1. Find the iPad: `xcrun devicectl list devices` shows it as a row with an
   iPad model (`iPad13,…`) and «physical»; simulated iPads do not count.
   `cd app && flutter devices` lists it by the same name, «(wireless)»
   over Wi-Fi, and its id. «available (paired)» (Wi-Fi) and «connected»
   (cable) both do. If no physical iPad is listed, or it is
   «unavailable», stop and report that the one-time pairing below
   is needed, or that the iPad must be unlocked and on the same Wi-Fi.
2. `flutter run --release --no-resident -d <id>` builds (about a minute),
   installs and starts the app.
3. If it ends with «Could not run build/ios/iphoneos/Runner.app»: the build is
   there, install it directly:
   `xcrun devicectl device install app --device <id> build/ios/iphoneos/Runner.app`,
   then start it:
   `xcrun devicectl device process launch --device <id> ch.tellbow.schwingen`.
   «Device is busy (Connecting to …)» or «disconnected immediately» mean
   the iPad is locked or asleep: stop and report that. Do not build again;
   the next try needs only these two commands.
4. Signing: as in the `iphone-install` skill. If
   `security find-identity -v -p codesigning` finds no valid identity,
   Apple's WWDR G3 intermediate certificate is missing from the keychain
   (https://www.apple.com/certificateauthority/AppleWWDRCAG3.cer): report
   that, do not change the keychain. «No Accounts» means the shell cannot
   reach the keychain: run the build outside the sandbox. «No profiles
   for 'ch.tellbow.schwingen' were found» or «device not registered»: the
   iPad was not yet in Xcode (pairing step 3); report that.

## One-time pairing (the user does it; report it as needed)

1. Connect the iPad by cable, unlock it, tap «Vertrauen» (Trust).
2. On the iPad: Einstellungen › Datenschutz & Sicherheit › Entwicklermodus
   on, restart, confirm. The switch shows only after the iPad has been
   connected to Xcode once.
3. In Xcode: Window › Devices and Simulators, select the iPad and wait
   until it is prepared; then open `app/ios/Runner.xcworkspace` and build
   once (⌘B) with the iPad selected, so the profile includes it. Then the
   cable can go: a paired device connects over Wi-Fi by itself.

Answer in a few lines: the commit installed (`git describe --tags --always`),
the iPad's name, whether it is installed and started, or the step that
failed with its error message. If the iPad was locked or is not paired, say
so first, with the pairing steps when they are needed.
