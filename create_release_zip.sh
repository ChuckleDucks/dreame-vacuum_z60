#!/bin/bash
# Script to create dreame_vacuum.zip for release
# Usage: ./create_release_zip.sh

set -e

VERSION=$(grep -oP '"version": "\K[^"]+' custom_components/dreame_vacuum/manifest.json)
ZIP_NAME="dreame_vacuum.zip"
TEMP_DIR=$(mktemp -d)

echo "Creating release zip for version: $VERSION"
echo "Temporary directory: $TEMP_DIR"

# Copy the integration directory to temp location
cp -r custom_components/dreame_vacuum "$TEMP_DIR/"

# Create zip file from the integration directory
cd "$TEMP_DIR"
zip -r "$ZIP_NAME" dreame_vacuum/ > /dev/null

# Move zip to original directory
mv "$ZIP_NAME" "$OLDPWD/"

# Cleanup
cd "$OLDPWD"
rm -rf "$TEMP_DIR"

echo "✓ Created $ZIP_NAME"
echo "✓ File size: $(du -h $ZIP_NAME | cut -f1)"
echo ""
echo "Next steps:"
echo "1. Create a GitHub release with tag: $VERSION"
echo "2. Attach $ZIP_NAME to the release"
echo "3. The release URL should be: https://github.com/Tasshack/dreame-vacuum/releases/download/$VERSION/$ZIP_NAME"

