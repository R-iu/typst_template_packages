#!/usr/bin/env bash
set -euo pipefail

# Install Typst local packages from this repository into the user's Typst
# local package directory.
#
# Usage:
#   ./install.sh
# or:
#   TYPST_PACKAGE_DIR=/custom/path ./install.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Determine destination Typst package directory
if [[ -n "${TYPST_PACKAGE_DIR:-}" ]]; then
  DEST_DIR="${TYPST_PACKAGE_DIR}"
else
  case "$(uname -s)" in
    Linux*)
      # Default Typst data dir on Linux
      DEST_DIR="${XDG_DATA_HOME:-"$HOME/.local/share"}/typst/packages"
      ;;
    Darwin*)
      # Default Typst data dir on macOS
      DEST_DIR="$HOME/Library/Application Support/typst/packages"
      ;;
    MINGW*|MSYS*|CYGWIN*)
      # Default Typst data dir on Windows (Git Bash, MSYS2, Cygwin)
      DEST_DIR="${APPDATA:-$USERPROFILE/AppData/Roaming}/typst/packages"
      ;;
    *)
      echo "Unsupported OS: $(uname -s)"
      echo "Please set TYPST_PACKAGE_DIR to your Typst package directory."
      exit 1
      ;;
  esac
fi

echo "Installing Typst packages from: ${SCRIPT_DIR}/local"
echo "Destination Typst package dir: ${DEST_DIR}"

mkdir -p "${DEST_DIR}/local"

# Copy (not move) the packages so the git repo stays intact
cp -R "${SCRIPT_DIR}/local/"* "${DEST_DIR}/local/"

echo "Done."

