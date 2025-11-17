#!/bin/bash
# Script to create dreame_vacuum.zip for release
# Usage: ./create_release_zip.sh

set -e

VERSION=$(grep -oP '"version": "\K[^"]+' custom_components/dreame_vacuum/manifest.json)
ZIP_NAME="dreame_vacuum.zip"
TEMP_DIR=$(mktemp -d)

echo "Creating release zip for version: $VERSION"

# The zip should contain files at root level (not in custom_components/dreame_vacuum/)
# HACS will extract this into custom_components/dreame_vacuum/
# Use -j to junk paths and put files at root of zip
cd custom_components/dreame_vacuum
zip -r "../../$ZIP_NAME" . > /dev/null
cd ../..

# Cleanup (no temp dir needed anymore)

echo "✓ Created $ZIP_NAME"
echo "✓ File size: $(du -h $ZIP_NAME | cut -f1)"
echo ""
echo "Next steps:"
echo "1. Create a GitHub release with tag: $VERSION"
echo "2. Attach $ZIP_NAME to the release"
echo "3. The release URL should be: https://github.com/Tasshack/dreame-vacuum/releases/download/$VERSION/$ZIP_NAME"

