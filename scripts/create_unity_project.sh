#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Simple CI — Create Clean Unity Project
# Called by: unity-create-clean.yml
#
# Required env vars:
#   GH_PAT          GitHub Personal Access Token
#   PROJECT_NAME    Human-readable project name (e.g. "Basic Game")
# ─────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/derive_names.sh"

ORG="punsalgames"
PROJECTS_DIR="/Volumes/BuildDisk/Unity/Projects"
PROJECT_DIR="${PROJECTS_DIR}/${REPO_NAME}"
UNITY_VERSION="2022.3.62f3"
UNITY_BIN="/Volumes/BuildDisk/Unity/Hub/Editor/${UNITY_VERSION}/Unity.app/Contents/MacOS/Unity"
GITIGNORE_REPO="https://github.com/punsalgames/unity-project-gitignore.git"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Simple CI — Create Clean Unity Project"
echo "  Project:    ${PROJECT_NAME}"
echo "  Repo:       ${ORG}/${REPO_NAME}"
echo "  Bundle ID:  ${BUNDLE_ID}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -f "$UNITY_BIN" ]; then
  echo "❌ Unity editor not found at: $UNITY_BIN"
  exit 1
fi

mkdir -p "$PROJECTS_DIR"

echo "▶ Creating Unity project..."
"$UNITY_BIN" \
  -quit \
  -batchmode \
  -nographics \
  -createProject "$PROJECT_DIR" \
  -logFile /tmp/unity_create_${REPO_NAME}.log || {
    echo "❌ Unity project creation failed. Log:"
    cat /tmp/unity_create_${REPO_NAME}.log
    exit 1
  }
echo "✅ Unity project created at: $PROJECT_DIR"

echo "▶ Configuring project settings..."
SETTINGS_FILE="${PROJECT_DIR}/ProjectSettings/ProjectSettings.asset"
sed -i '' "s/applicationIdentifier: .*/applicationIdentifier: ${BUNDLE_ID}/" "$SETTINGS_FILE"
sed -i '' "s/productName: .*/productName: ${PROJECT_NAME}/" "$SETTINGS_FILE"
sed -i '' "s/companyName: .*/companyName: punsal/" "$SETTINGS_FILE"
echo "✅ ProjectSettings configured"

echo "▶ Creating version files..."
echo "1.0.0" > "${PROJECT_DIR}/version.txt"
echo "0" > "${PROJECT_DIR}/build_number.txt"
echo "0" > "${PROJECT_DIR}/rc_number.txt"
echo "✅ Version files created"

echo "▶ Fetching .gitignore..."
TEMP_DIR=$(mktemp -d)
git clone --depth=1 "$GITIGNORE_REPO" "$TEMP_DIR"
cp "$TEMP_DIR/.gitignore" "${PROJECT_DIR}/.gitignore"
rm -rf "$TEMP_DIR"
echo "✅ .gitignore applied"

echo "▶ Copying workflow templates..."
mkdir -p "${PROJECT_DIR}/.github/workflows"
cp "${SCRIPT_DIR}/../templates/workflows/"*.yml "${PROJECT_DIR}/.github/workflows/"
echo "✅ Workflow templates copied"

echo "▶ Generating README..."
cat > "${PROJECT_DIR}/README.md" << README
# ${PROJECT_NAME}

> Created: $(date +"%B %d, %Y")
> Bundle ID: \`${BUNDLE_ID}\`
> Unity: ${UNITY_VERSION} LTS
> Organization: [Simple](https://github.com/punsalgames)

## Getting Started

1. Clone this repository
2. Open Unity Hub → Add → select this folder
3. Open with Unity ${UNITY_VERSION} LTS

## Builds

| Build | Trigger | Debug Tools | Distribution |
|---|---|---|---|
| debug-android | manual (any branch except main) | ✅ SIMPLE_DEBUG | Firebase |
| debug-ios | manual (any branch except main) | ✅ SIMPLE_DEBUG | TestFlight |
| dev | auto on push to develop | ❌ | Firebase / TestFlight |
| release | manual on main | ❌ | Play Store / App Store |

## CI/CD

Powered by [Simple CI](https://github.com/punsalgames/Simple-CI).
README
echo "✅ README generated"

echo "▶ Initializing git..."
cd "$PROJECT_DIR"
git init
git add .
git commit -m "chore: initial project setup via Simple CI"
git branch -M main
git checkout -b develop
git checkout main
echo "✅ Git initialized"

echo "▶ Creating GitHub repo..."
curl -s -X POST \
  -H "Authorization: token ${GH_PAT}" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/orgs/${ORG}/repos" \
  -d "{
    \"name\": \"${REPO_NAME}\",
    \"description\": \"${PROJECT_NAME} — A Simple game\",
    \"private\": false,
    \"auto_init\": false
  }"
echo "✅ GitHub repo created"

echo "▶ Pushing branches..."
git remote add origin "https://${GH_PAT}@github.com/${ORG}/${REPO_NAME}.git"
git push -u origin main
git push -u origin develop
echo "✅ Pushed to GitHub"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Done! https://github.com/${ORG}/${REPO_NAME}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
