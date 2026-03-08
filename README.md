# Simple CI

> A personal CI solution for mobile game development.
> Organization: [Simple](https://github.com/punsalgames)
> Build machine: `pmr-mini` (Mac mini M4, ARM64)

---

## Overview

Simple CI provides automated Unity project creation and build pipelines for iOS and Android mobile games. All workflows run on a self-hosted runner on `pmr-mini`.

---

## Project Creation Workflows

| Workflow | Description |
|---|---|
| `unity-create-clean` | Creates a fresh Unity 2022.3 LTS project from scratch |
| `unity-create-template` | Creates a project from a GitHub template repo |

### Input

| Input | Example | Notes |
|---|---|---|
| `project_name` | `Basic Game` | Everything else is derived automatically |
| `template_repo` | `punsalgames/unity-project-template` | Template workflow only |

### Auto-derived values

| Value | Example | How |
|---|---|---|
| Repo name | `Basic-Game` | Spaces → dashes |
| Bundle suffix | `basicgame` | Lowercase, no spaces |
| Bundle ID | `com.punsal.basicgame` | `com.punsal.` + suffix |

### What gets created

Every new project is born with:
- ✅ Unity project configured (bundle ID, product name, company name)
- ✅ `version.txt`, `build_number.txt`, `rc_number.txt`
- ✅ `.gitignore` from [punsalgames/unity-project-gitignore](https://github.com/punsalgames/unity-project-gitignore)
- ✅ Auto-generated README
- ✅ Build workflows scaffolded into `.github/workflows/`
- ✅ `main` and `develop` branches

---

## Build Workflows (scaffolded into game repos)

| Workflow | Trigger | Branch | SIMPLE_DEBUG | Distribution |
|---|---|---|---|---|
| `build-debug-android` | manual | any except main | ✅ | Firebase |
| `build-debug-ios` | manual | any except main | ✅ | TestFlight |
| `build-dev` | push to develop | develop | ❌ | Firebase + TestFlight |
| `build-release` | manual | main only | ❌ | Play Store + App Store |

### Versioning

| File | Purpose | Updated by |
|---|---|---|
| `version.txt` | Semantic version (`1.0.0`) | You, manually |
| `build_number.txt` | Global build counter (`b122`) | Every build, auto |
| `rc_number.txt` | RC counter, resets on version bump | Dev builds, auto |

### Tags

| Tag | Example | Created on |
|---|---|---|
| `rc/X.Y.Z-N` | `rc/1.0.0-3` | Every dev build |
| `vX.Y.Z` | `v1.0.0` | Every release build |

---

## Branching Strategy
main          ← production, what's live on stores
develop       ← active development
feature/*     ← new features
fix/*         ← bug fixes

---

## Fastlane

All game repos share a single Fastfile located at:
~/Developer/Simple-CI/templates/fastlane/Fastfile

Update once → all games get the update automatically.

---

## Infrastructure

| Component | Detail |
|---|---|
| Build machine | Mac mini M4, `pmr-mini` |
| Runner | Self-hosted, org-level, ARM64 |
| Unity | 2022.3 LTS at `/Volumes/BuildDisk/Unity/Hub/Editor` |
| Projects | `/Volumes/BuildDisk/Unity/Projects` |
| Remote access | Tailscale |

---

## Repo Structure
Simple-CI/
├── .github/
│   └── workflows/
│       ├── unity-create-clean.yml
│       └── unity-create-template.yml
├── scripts/
│   ├── derive_names.sh
│   ├── build_helpers.sh
│   ├── create_unity_project.sh
│   └── create_unity_project_from_template.sh
├── templates/
│   ├── fastlane/
│   │   ├── Fastfile
│   │   ├── Appfile
│   │   └── Gemfile
│   └── workflows/
│       ├── build-debug-android.yml
│       ├── build-debug-ios.yml
│       ├── build-dev.yml
│       └── build-release.yml
├── INSTALL.md
├── TESTING.md
└── README.md

---

*Part of the Simple personal game development pipeline.*
