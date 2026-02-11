# Cove - A Mock Curated Marketplace
<img width="1630" alt="Screenshot 2025-04-23 at 12 36 21 AM" src="https://github.com/user-attachments/assets/a6194687-e7ce-4ca4-a534-b6852527d8ad" />

## About

Cove is my passion project of a mock, curated marketplace of ethical businesses and quality producers. I work on this project to explore native iOS Development, UX/UI design, mobile CI/CD, and the Google Cloud Platform with Firebase.

This repository contains the source files for the Xcode project.
- Supports iOS 18+
- Uses Firebase for backend
  - Firebase Auth
  - Firestore
  - Cloud Storage

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
- [ ] Search products and available filters.
- [ ] Pages for individual stores/businesses/artists.
- [ ] Stock checking and shipping calculation.
- [ ] Product and producer promotions.
- [ ] Product reviews and ratings.
- [ ] Ability to favorite products.
- [ ] Friend system for seeing what they've reviewed and favorited.
- [ ] Personalized product recommendations (Based on favorites, and purchase history).

## Signup Walkthrough

- Left is signing up with a Social Provider (Google). Facebook sign up is also supported. Once I get an Apple Developer Account, Apple sign up will also be supported.
- Right is signing up with an email (Firebase).
- Both methods will create a user entry with Firebase Authentication.

<div>
  <img src="https://user-images.githubusercontent.com/24427074/233470161-c6d13253-7608-4e27-b48b-ebde8a243fb6.gif" width="20%"/>
  <img src="https://user-images.githubusercontent.com/24427074/233473427-2d0a78e6-3087-437e-a204-21d6fec12585.gif" width="20%"/>
</div>

## Home and Product Details Walkthrough

- This is what is currently in place for the Home view and clicking to view a product.

<img src="https://user-images.githubusercontent.com/24427074/233480170-2558c859-fb3a-4580-9366-eb394ee4edab.gif" width="20%"/>

GIFs created with [Kap](https://getkap.co/).

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
- **PR Checks**: Builds and tests run automatically on every pull request
- **TestFlight Deployment**: Auto-deploys to TestFlight on every merge to `main`
- **App Store Submission**: Release workflow triggered by creating a new GitHub release

See [CI/CD Workflows Documentation](docs/CI_CD_WORKFLOWS.md) for complete setup and usage instructions.

## More to come

Everything seen so far is subject to change overtime as I move along with development.

A simple roadmap for Cove can be found at https://github.com/users/danicajiao/projects/2.
