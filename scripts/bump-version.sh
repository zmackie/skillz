#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <patch|minor|major>"
  echo ""
  echo "Bumps the version in plugin.json, commits, tags, and optionally pushes."
  echo ""
  echo "Options:"
  echo "  --push    Push commit and tag to origin after bumping"
  echo "  --debug   Show extra logging"
  exit 1
}

PUSH=false
DEBUG=false
BUMP=""

for arg in "$@"; do
  case "$arg" in
    patch|minor|major) BUMP="$arg" ;;
    --push) PUSH=true ;;
    --debug) DEBUG=true ;;
    *) usage ;;
  esac
done

[[ -z "$BUMP" ]] && usage

debug() { [[ "$DEBUG" == "true" ]] && echo "[debug] $*" || true; }

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN="$ROOT/.claude-plugin/plugin.json"

# Read current version
CURRENT=$(python3 -c "import json; print(json.load(open('$PLUGIN'))['version'])")
debug "Current version: $CURRENT"

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

case "$BUMP" in
  major) ((MAJOR++)); MINOR=0; PATCH=0 ;;
  minor) ((MINOR++)); PATCH=0 ;;
  patch) ((PATCH++)) ;;
esac

NEW="${MAJOR}.${MINOR}.${PATCH}"
echo "Bumping version: $CURRENT → $NEW"

# Update plugin.json
python3 -c "
import json
with open('$PLUGIN', 'r') as f:
    data = json.load(f)
data['version'] = '$NEW'
with open('$PLUGIN', 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
"
debug "Updated plugin.json"

# Commit and tag
cd "$ROOT"
git add .claude-plugin/plugin.json
git commit -m "chore: bump version to $NEW"
git tag "v$NEW"

echo "Created commit and tag v$NEW"

if [[ "$PUSH" == "true" ]]; then
  git push origin HEAD
  git push origin "v$NEW"
  echo "Pushed to origin"
else
  echo ""
  echo "Run the following to push:"
  echo "  git push origin HEAD && git push origin v$NEW"
fi
