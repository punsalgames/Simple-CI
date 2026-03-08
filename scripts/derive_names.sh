#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Simple CI — Derive repo name and bundle suffix from project name
#
# Usage: source derive_names.sh
# Requires: PROJECT_NAME env var
#
# Exports:
#   REPO_NAME       e.g. "Basic Game"     → "Basic-Game"
#   BUNDLE_SUFFIX   e.g. "Basic Game"     → "basicgame"
#   BUNDLE_ID       e.g. "Basic Game"     → "com.punsal.basicgame"
# ─────────────────────────────────────────────────────────────────────────────

if [ -z "${PROJECT_NAME:-}" ]; then
  echo "❌ PROJECT_NAME is not set"
  exit 1
fi

# Repo name: spaces → dashes, preserve casing
REPO_NAME=$(echo "$PROJECT_NAME" | sed 's/ /-/g')

# Bundle suffix: lowercase, remove spaces
BUNDLE_SUFFIX=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr -d ' -')

# Full bundle ID
BUNDLE_ID="com.punsal.${BUNDLE_SUFFIX}"

export REPO_NAME
export BUNDLE_SUFFIX
export BUNDLE_ID
