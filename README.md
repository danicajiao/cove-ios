# Cove - A Curated Marketplace
[![CI - Main](https://github.com/danicajiao/cove-ios/actions/workflows/ci-main.yml/badge.svg)](https://github.com/danicajiao/cove-ios/actions/workflows/ci-main.yml)

<img width="1630" alt="Screenshot 2025-04-23 at 12 36 21 AM" src="https://github.com/user-attachments/assets/a6194687-e7ce-4ca4-a534-b6852527d8ad" />

## About

Cove is my passion project — a curated marketplace of conscious businesses and quality producers. I work on this project to explore native iOS development, UX/UI design, mobile CI/CD, the Google Cloud Platform with Firebase, and AI-assisted development workflows.

The project also serves as a testbed for agentic development — using AI agents to automate parts of the development process, such as implementing Figma designs directly into SwiftUI and orchestrating multi-step coding tasks from GitHub issues.

## Tech Stack

- **Platform:** iOS 18+
- **Language:** Swift / SwiftUI
- **Backend:** Firebase (Auth, Firestore, Cloud Storage)
- **CI/CD:** GitHub Actions + Fastlane

## Getting Started

See [Quick Start Guide](docs/QUICK_START.md) to get the project building locally.

## Design Goals

- [x] Log in with popular social providers (Ex. Google, Facebook, etc).
- [x] Secure account creation with Firebase Authentication.
- [x] Support for wide range of varying products.
  - [x] Coffee
  - [x] Music
  - [x] Apparel
  - [ ] Home
  - [ ] Beverages
  - [ ] Tea
- [x] Persistent login state.
- [x] Fetch data in real-time from Google Cloud Platform.
- [x] Ability to favorite products.
- [ ] Search products and available filters.
- [ ] Pages for individual stores/businesses/artists.
- [ ] Stock checking and shipping calculation.
- [ ] Product and producer promotions.
- [ ] Product reviews and ratings.
- [ ] Friend system for seeing what they've reviewed and favorited.
- [ ] Personalized product recommendations (Based on favorites, and purchase history).

## Contributing

### Branching
This project follows trunk-based development where each branch is tied to an Issue. This projects Issues can be found [here](https://github.com/danicajiao/cove-ios/issues).

For example, to start working on an Issue with id `#14` and label `feature` the convention is to name the branch `feature/14-issue-desc`. That is, all lowercase, starting
with the label, followed by a forward-slash, then a short description starting with the Issue id in kebab case.

Here are some more examples:
- `feature/21-another-desc`
- `bug/3-bug-desc`
- `docs/10-doc-impl`

### Pull Requests
In order to make best use of GitHubs auto-referencing feature, pull request titles or descriptions should contain keywords like "closes" or "resolves" followed by the Issue number it relates to like follows:
- `This PR closes #21`
- `This PR resolves danicajiao/cove-ios#3`

This will then auto-link the PR to the issue(s) and will close them once the PR is merged.

### CI/CD
This project uses automated CI/CD workflows for iOS app deployment:
- **PR Checks**: Linting runs automatically on every pull request
- **TestFlight Deployment**: Manual deployment via workflow dispatch
- **App Store Submission**: Manual deployment via workflow dispatch

See [CI/CD Workflows Documentation](docs/CI_CD_WORKFLOWS.md) for complete setup and usage instructions.

## Roadmap

A simple roadmap for Cove can be found at https://github.com/users/danicajiao/projects/2.
