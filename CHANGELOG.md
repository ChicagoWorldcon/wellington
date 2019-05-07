# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Detection of Stripe test keys to change colours on pages to distinguish between production and test systems
- CoNZealand images are now served from the project rather than GitHub to consolidate infrastructure
- When purchasing a new membership, if you've got existing memberships you now get linked to the 'Review Memberships'
  section with a helpful message
- Added Policy and Terms of service to CoNZealand pages

### Changed
- URLs for charging a person have been updated to use Purchase for consistency
- Fixed Kansa and Presupport import methods to set "active" correctly on older records
- Allow database name to be configurable on production builds for cheep staging costs
- Updated most gems in the project including Rails
- Replaced deprecated SASS gem with SASSC
- Redirect to current page on login, puts you on the "new membership" or "review memberships" pages

### Removed
- Nothing significant in this release

## Tag 1.0.0 - 2019-03-29

### Added
- Basic forms for purchasing memberships based on CoNZealand paper forms
- Payments, including pay by installment
- Upgrades between different membership types
- Login through email links that last 10 minutes
- Basic support area that lists memberships
- Concept of "active" for membership pricing for price rotation and disabling memberships
- Concept of "active" for membership held and claim over membership
- Concept of "active" for claim over membership for transfers and history of ownership
- Theme concept area so we may cater for different cons
- Basic mailers to setup descriptions about payment
- Basic docker images for developers and production
- Gitlab CI pipelines that build docker images for deploy
- Command line based membership transfer
- Membership numbers start at 100 to give room for special guests

### Changed
- Kansa members were renumbered to start at 2000
- Old Kansa login links now say "this link has expired"

### Removed
- Nothing significant in this release
