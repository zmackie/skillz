#!/usr/bin/env bash
set -euo pipefail

DEBUG=${DEBUG:-false}
ERRORS=0
WARNINGS=0

debug() { [[ "$DEBUG" == "true" ]] && echo "  [debug] $*" || true; }
error() { echo "  ❌ $*"; ERRORS=$((ERRORS + 1)); }
warn()  { echo "  ⚠️  $*"; WARNINGS=$((WARNINGS + 1)); }
pass()  { echo "  ✅ $*"; }

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# ─── Validate plugin.json ────────────────────────────────────────────
echo "── plugin.json ──"

PLUGIN="$ROOT/.claude-plugin/plugin.json"
if [[ ! -f "$PLUGIN" ]]; then
  error "plugin.json not found at $PLUGIN"
  exit 1
fi

# Valid JSON?
if ! python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$PLUGIN" 2>/dev/null; then
  error "plugin.json is not valid JSON"
  exit 1
fi
pass "Valid JSON"

# Required fields
for field in name version description; do
  val=$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d.get('$field',''))" "$PLUGIN")
  if [[ -z "$val" ]]; then
    error "Missing required field: $field"
  else
    debug "$field = $val"
    pass "Has field '$field'"
  fi
done

# Semver check
VERSION=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1])).get('version',''))" "$PLUGIN")
if [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  pass "Version '$VERSION' is valid semver"
else
  error "Version '$VERSION' is not valid semver (expected X.Y.Z)"
fi

# ─── Validate each skill ─────────────────────────────────────────────
echo ""
echo "── Skills ──"

SKILLS_DIR="$ROOT/skills"
if [[ ! -d "$SKILLS_DIR" ]]; then
  error "skills/ directory not found"
  exit 1
fi

SKILL_COUNT=0

for skill_dir in "$SKILLS_DIR"/*/; do
  [[ -d "$skill_dir" ]] || continue
  dirname=$(basename "$skill_dir")
  SKILL_COUNT=$((SKILL_COUNT + 1))
  echo ""
  echo "  ── $dirname ──"

  SKILL_FILE="$skill_dir/SKILL.md"

  # Directory name: lowercase + hyphens only
  if [[ "$dirname" =~ ^[a-z][a-z0-9-]*$ ]]; then
    pass "Directory name is lowercase-hyphenated"
  else
    error "Directory name '$dirname' must be lowercase with hyphens only"
  fi

  # SKILL.md exists
  if [[ ! -f "$SKILL_FILE" ]]; then
    error "SKILL.md not found"
    continue
  fi
  pass "SKILL.md exists"

  # Under 500 lines
  lines=$(wc -l < "$SKILL_FILE" | tr -d ' ')
  if (( lines > 500 )); then
    error "SKILL.md is $lines lines (max 500)"
  else
    pass "SKILL.md is $lines lines (≤500)"
  fi

  # Has YAML frontmatter
  first_line=$(head -1 "$SKILL_FILE")
  if [[ "$first_line" != "---" ]]; then
    error "Missing YAML frontmatter (file must start with ---)"
    continue
  fi

  # Extract frontmatter
  frontmatter=$(sed -n '1,/^---$/{ /^---$/d; p; }' "$SKILL_FILE" | tail -n +1)
  debug "frontmatter: $frontmatter"

  # Closing --- exists
  closing=$(awk 'NR>1 && /^---$/{print NR; exit}' "$SKILL_FILE")
  if [[ -z "$closing" ]]; then
    error "Frontmatter not closed (missing second ---)"
    continue
  fi
  pass "Frontmatter is properly delimited"

  # Required frontmatter fields: name, description
  for field in name description; do
    if echo "$frontmatter" | grep -qE "^${field}:"; then
      pass "Has frontmatter field '$field'"
    else
      error "Missing frontmatter field '$field'"
    fi
  done

  # Frontmatter name matches directory name
  fm_name=$(echo "$frontmatter" | grep -E "^name:" | sed 's/^name:[[:space:]]*//' | tr -d '"' | tr -d "'")
  if [[ -n "$fm_name" && "$fm_name" != "$dirname" ]]; then
    error "Frontmatter name '$fm_name' does not match directory '$dirname'"
  elif [[ -n "$fm_name" ]]; then
    pass "Frontmatter name matches directory"
  fi

  # Has at least one markdown heading
  body=$(awk "NR>$closing" "$SKILL_FILE")
  if echo "$body" | grep -qE "^#+ "; then
    pass "Has markdown heading(s)"
  else
    warn "No markdown headings found in body"
  fi

  # Description under 250 chars
  desc=$(echo "$frontmatter" | grep -E "^description:" | sed 's/^description:[[:space:]]*//' | tr -d '"' | tr -d "'")
  if [[ -n "$desc" ]] && (( ${#desc} > 250 )); then
    warn "Description is ${#desc} chars (recommended ≤250)"
  fi
done

# ─── Summary ──────────────────────────────────────────────────────────
echo ""
echo "── Summary ──"
echo "  Skills checked: $SKILL_COUNT"
echo "  Errors: $ERRORS"
echo "  Warnings: $WARNINGS"

if (( ERRORS > 0 )); then
  echo ""
  echo "FAILED with $ERRORS error(s)"
  exit 1
fi

echo ""
echo "ALL CHECKS PASSED"
exit 0
