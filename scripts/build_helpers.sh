#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Simple CI — Shared build helpers
#
# Usage: source build_helpers.sh
# ─────────────────────────────────────────────────────────────────────────────

# Read current version from version.txt
get_version() {
  cat "${PROJECT_DIR}/version.txt"
}

# Read and increment build number, commit back
increment_build_number() {
  local current
  current=$(cat "${PROJECT_DIR}/build_number.txt")
  local next=$((current + 1))
  echo "$next" > "${PROJECT_DIR}/build_number.txt"
  echo "b${next}"
}

# Read and increment RC number, reset if version changed
increment_rc_number() {
  local version
  version=$(get_version)
  local current_rc
  current_rc=$(cat "${PROJECT_DIR}/rc_number.txt")

  local last_rc_tag
  last_rc_tag=$(git tag --list "rc/${version}-*" | sort -t- -k2 -n | tail -1)

  if [ -z "$last_rc_tag" ]; then
    echo "1" > "${PROJECT_DIR}/rc_number.txt"
    echo "1"
  else
    local next=$((current_rc + 1))
    echo "$next" > "${PROJECT_DIR}/rc_number.txt"
    echo "$next"
  fi
}

# Inject scripting define symbols into ProjectSettings.asset
inject_defines() {
  local defines="$1"
  local settings="${PROJECT_DIR}/ProjectSettings/ProjectSettings.asset"

  cp "$settings" "${settings}.bak"

  sed -i '' "/Android:/ s/$/ ${defines}/" "$settings"
  sed -i '' "/iPhone:/ s/$/ ${defines}/" "$settings"

  echo "✅ Injected defines: ${defines}"
}

# Restore ProjectSettings.asset after build
restore_defines() {
  local settings="${PROJECT_DIR}/ProjectSettings/ProjectSettings.asset"
  if [ -f "${settings}.bak" ]; then
    mv "${settings}.bak" "$settings"
    echo "✅ ProjectSettings restored"
  fi
}

# Commit version files back to current branch
commit_version_files() {
  local message="$1"
  cd "$PROJECT_DIR"
  git add version.txt build_number.txt rc_number.txt
  git commit -m "chore: ${message} [skip ci]"
  git push origin HEAD
}
