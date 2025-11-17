#!/usr/bin/env python3
"""
Script to create dreame_vacuum.zip for release
Usage: python create_release_zip.py
"""

import json
import os
import shutil
import zipfile
from pathlib import Path

def main():
    # Read version from manifest
    manifest_path = Path("custom_components/dreame_vacuum/manifest.json")
    with open(manifest_path, "r") as f:
        manifest = json.load(f)
    version = manifest["version"]
    
    zip_name = "dreame_vacuum.zip"
    integration_dir = Path("custom_components/dreame_vacuum")
    
    print(f"Creating release zip for version: {version}")
    
    # Create zip file
    # The zip should contain files at root level (not in custom_components/dreame_vacuum/)
    # HACS will extract this into custom_components/dreame_vacuum/
    with zipfile.ZipFile(zip_name, "w", zipfile.ZIP_DEFLATED) as zipf:
        for file_path in integration_dir.rglob("*"):
            if file_path.is_file():
                # Add file to zip with path relative to integration_dir
                # This puts files at root of zip: __init__.py, config_flow.py, etc.
                arcname = file_path.relative_to(integration_dir)
                zipf.write(file_path, arcname)
    
    file_size = os.path.getsize(zip_name) / (1024 * 1024)  # Size in MB
    print(f"✓ Created {zip_name}")
    print(f"✓ File size: {file_size:.2f} MB")
    print()
    print("Next steps:")
    print(f"1. Create a GitHub release with tag: {version}")
    print(f"2. Attach {zip_name} to the release")
    print(f"3. The release URL should be: https://github.com/Tasshack/dreame-vacuum/releases/download/{version}/{zip_name}")

if __name__ == "__main__":
    main()

