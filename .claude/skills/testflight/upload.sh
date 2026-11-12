#!/bin/zsh
# Builds the iOS app of the release tag checked out and uploads it to App
# Store Connect (TestFlight, and the build an App Store version takes).
# Usage, in a checkout of the tag:
#   ASC_KEY_ID=… ASC_ISSUER_ID=… .claude/skills/testflight/upload.sh <export dir> [<export options plist>]
# The key file is ~/.appstoreconnect/private_keys/AuthKey_$ASC_KEY_ID.p8.
set -eu

out=${1:?export directory}
cd "$(git rev-parse --show-toplevel)/app"
export_options=${2:-$PWD/ios/ExportOptions-upload.plist}

tag=$(git describe --tags --exact-match)
if [[ -n $(git status --porcelain) ]]; then
  echo "uncommitted changes: build from the tag only" >&2
  exit 1
fi

# The error at the end, creating the IPA, does not matter: the archive is
# what is signed below.
flutter build ipa --build-name=${tag#v} --build-number=$(git rev-list --count HEAD) || true
archive=build/ios/archive/Runner.xcarchive
if [[ ! -d $archive ]]; then
  echo "no archive" >&2
  exit 1
fi

xcodebuild -exportArchive -archivePath $archive -exportOptionsPlist "$export_options" -exportPath "$out" \
  -authenticationKeyPath ~/.appstoreconnect/private_keys/AuthKey_$ASC_KEY_ID.p8 \
  -authenticationKeyID $ASC_KEY_ID -authenticationKeyIssuerID $ASC_ISSUER_ID
echo "uploaded ${tag#v} build $(git rev-list --count HEAD)"
