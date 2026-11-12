---
name: testflight
description: Builds the Tellbow iOS app of the last release tag and uploads it to App Store Connect for TestFlight, signed on this Mac (Apple Distribution certificate, App Store profile «Schwingen App Store») and uploaded with an App Store Connect API key, without the user. Only when the user asks for a TestFlight or App Store build.
disable-model-invocation: true
---

# Upload a build to TestFlight

An upload goes to Apple and cannot be taken back; a build number counts
only once. Build from a release tag (the `release` skill), so the version
in TestFlight is the code of a release. The app downloads its data from
the newest GitHub release by itself: a data-only release needs no new
build.

1. **On the tag:** `git describe --tags --exact-match` names the release
   (`vX.Y.Z`) and `git status` is clean. When `main` has moved on since
   the tag, build in a worktree of it instead
   (`git worktree add --detach <scratchpad>/rel-X.Y.Z vX.Y.Z`, removed
   afterwards, and run `main`'s `upload.sh` there); tags without
   `app/ios/ExportOptions-upload.plist` need the path of `main`'s as
   second argument.
2. **Build and upload** (a few minutes), from the checkout of the tag,
   with the key id and issuer id from `CLAUDE.local.md` (the key's file in
   `~/.appstoreconnect/private_keys/` is never read or printed):
   ```sh
   ASC_KEY_ID=<key id> ASC_ISSUER_ID=<issuer id> \
     .claude/skills/testflight/upload.sh <scratchpad>/export [<main's app/ios/ExportOptions-upload.plist>]
   ```
   It archives with the tag's version and the commit count as build
   number and signs on this Mac with the «Apple Distribution» certificate
   (in the keychain) and the App Store profile «Schwingen App Store»
   (`app/ios/ExportOptions-upload.plist`), uploaded with the App Store
   Connect API key («App Manager», the same key as Alvyo's: one team).
   Xcode's own Apple ID session is not used: the command line could not
   renew it. The error while creating the IPA after the archive does not
   matter.
   «No Accounts» or no signing identity: the shell cannot reach the
   keychain; run it outside the sandbox.
   «Provisioning profile … not found» or «expired»: the profile is renewed
   once a year in the developer portal (Profiles → «Schwingen App Store» →
   Edit → Generate; download), by the user; then install it as below.
   «Upload succeeded» and «EXPORT SUCCEEDED» mean it is in App Store
   Connect, processing (5–30 minutes until TestFlight shows it).
3. **Report** the version and build number. «The bundle version must be
   higher» means that build number was uploaded already: a new commit (and
   release) gives the next one; do not change the number by hand.

Testers get the build after Apple's processing; a build for external
testers needs Beta App Review in App Store Connect the first time per
version, which the user does there. For the App Store itself (the
version, «Neuerungen», this build, App Review): the `app-store` skill.

## One-time setup (the user does it; report it as needed)

1. Developer portal → Identifiers: the App ID `ch.tellbow.schwingen`
   (Xcode may have registered it already).
2. Profiles → + → «App Store Connect», App ID `ch.tellbow.schwingen`,
   certificate «Apple Distribution», name «Schwingen App Store»;
   download. Double-clicking does not install it; Claude does:
   `security cms -D -i ~/Downloads/Schwingen_App_Store.mobileprovision | plutil -extract UUID raw -o - -`
   gives its UUID, then copy the file to
   `~/Library/Developer/Xcode/UserData/Provisioning Profiles/<UUID>.mobileprovision`.
3. App Store Connect → Apps → + → New App: iOS, name «Schwingen»
   (French: «Lutte suisse»), primary language German, bundle ID
   `ch.tellbow.schwingen`.
