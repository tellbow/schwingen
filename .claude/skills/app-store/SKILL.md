---
name: app-store
description: Publishes a release of the Tellbow iOS app on the App Store through the App Store Connect API - the App Store version, «Neuerungen» in German and French, the build uploaded by the testflight skill, and the submission to App Review. Only when the user asks for an App Store release.
disable-model-invocation: true
---

# Publish a version on the App Store

The version on the App Store is a release tag `vX.Y.Z` (the `release`
skill) whose build the `testflight` skill uploaded. `asc.py` talks to the
App Store Connect API
(https://developer.apple.com/documentation/appstoreconnectapi) with the
same key as the upload: its key id and issuer id are in `CLAUDE.local.md`;
its file in `~/.appstoreconnect/private_keys/` is read by the script only,
never printed. Run it with `uv run` (it brings PyJWT):

```sh
export ASC_KEY_ID=<key id> ASC_ISSUER_ID=<issuer id>
uv run .claude/skills/app-store/asc.py status X.Y.Z
```

1. **The build:** uploaded by the `testflight` skill (its `upload.sh`).
   `status X.Y.Z` lists the builds of that version and their processing
   (`PROCESSING`, then `VALID`, 5–30 minutes after the upload).
2. **«Neuerungen»:** one or two short sentences per language, German
   (Swiss spelling, «ss») and French, on what changed in the app since
   the last App Store version (`git log --oneline vPREVIOUS..vX.Y.Z -- app/`),
   for users, not developers. Not for the first version: Apple takes
   none there.
3. **Prepare:**
   `prepare X.Y.Z --text de "…" --text fr "…"` waits for the build to be
   `VALID` (45 minutes at most), creates the App Store version (or gives
   the one still in preparation, such as a new app's «1.0», this number),
   released after approval, sets «Neuerungen» in each language the App
   Store has (`de-CH` and `de-DE` take `de`, `fr-FR` `fr`) and chooses the
   build: the newest of that version, or `--build N`. Everything else
   (description, keywords, screenshots, privacy, age rating) App Store
   Connect copies from the last version; change it there.
   A language without `--text` stops it. A version already submitted or
   on sale stops it: tell the user which.
4. **Show and ask:** `status X.Y.Z` shows the state, the chosen build and
   the texts. Show them to the user and ask with a question box before
   submitting: a submission goes to Apple and cannot be taken back here
   (only cancelled in App Store Connect while waiting for review).
5. **Submit:** `submit X.Y.Z` creates the review submission with the
   version and submits it: `WAITING_FOR_REVIEW`, then `IN_REVIEW`, then
   released by itself once approved. Report the state; Apple writes to
   the account's e-mail when it is approved or rejected, and a rejection
   is read in App Store Connect (Resolution Center).

Errors come back as App Store Connect's own `title: detail` (e.g. a
missing export compliance answer: `ITSAppUsesNonExemptEncryption` is
`false` in `Info.plist`, so it should not happen; a screenshot size
missing for a device class). The key needs the role «App Manager».

## The first version (once, in App Store Connect, by the user)

The API cannot fill these for a new app; `submit` fails until they are
there. Offer to draft the texts.

- **App Information:** name, subtitle, category Sports, content rights
  (the app shows no third-party content it has no rights to), age rating
  questionnaire (all «None»: 4+).
- **Pricing and Availability:** free, the countries.
- **App Privacy:** the privacy policy URL (`https://schwingen.tellbow.ch/privacy`
  and `/fr/privacy`) and the data: «Fehler melden» sends the user's text, an optional
  screenshot, the app version and the device; not linked to the user, no
  tracking. Settings stay on the phone.
- **The version page**, per language (German, French): description,
  keywords, support URL (`https://schwingen.tellbow.ch`), screenshots for
  the 6.9″ iPhone and, since the app runs on iPad
  (`TARGETED_DEVICE_FAMILY = "1,2"`), the 13″ iPad; the simulator takes
  them (`xcrun simctl io <id> screenshot`, iPhone 17 Pro Max and iPad Pro
  13-inch).
- **App Review Information:** contact, «no sign-in required».
