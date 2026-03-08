#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Simple CI — Create Unity Project from Template
# Called by: unity-create-template.yml
#
# Required env vars:
#   GH_PAT          GitHub Personal Access Token
#   PROJECT_NAME    Human-readable project name (e.g. "Basic Game")
#   TEMPLATE_REPO   Template repo (e.g. punsalgames/unity-project-template)
# ─────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/derive_names.sh"

ORG="punsalgames"
PROJECTS_DIR="/Volumes/BuildDisk/Unity/Projects"
PROJECT_DIR="${PROJECTS_DIR}/${REPO_NAME}"
UNITY_VERSION="2022.3.62f1"
GITIGNORE_REPO="https://github.com/punsalgames/unity-project-gitignore.git"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Simple CI — Create Unity Project from Template"
echo "  Project:    ${PROJECT_NAME}"
echo "  Repo:       ${ORG}/${REPO_NAME}"
echo "  Bundle ID:  ${BUNDLE_ID}"
echo "  Template:   ${TEMPLATE_REPO}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "▶ Creating GitHub repo from template..."
curl -s -X POST \
  -H "Authorization: token ${GH_PAT}" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/${TEMPLATE_REPO}/generate" \
  -d "{
    \"owner\": \"${ORG}\",
    \"name\": \"${REPO_NAME}\",
    \"description\": \"${PROJECT_NAME} — A Simple game\",
    \"private\": false,
    \"include_all_branches\": false
  }"

echo "▶ Waiting for GitHub..."
sleep 5
echo "✅ GitHub repo created from template"

echo "▶ Cloning repo..."
mkdir -p "$PROJECTS_DIR"
git clone "https://${GH_PAT}@github.com/${ORG}/${REPO_NAME}.git" "$PROJECT_DIR"
cd "$PROJECT_DIR"
echo "✅ Cloned to: $PROJECT_DIR"

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

echo "▶ Creating develop branch and pushing..."
git checkout -b develop
git add .
git commit -m "chore: configure project via Simple CI"
git push -u origin develop
git checkout main
git push origin main
echo "✅ Pushed to GitHub"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Done! https://github.com/${ORG}/${REPO_NAME}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
