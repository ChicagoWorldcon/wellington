# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Turned on [Content Security Policy (CSP)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy)
  for the site for security hygiene
- Support can now transfer memberships between users from a user's detail form

### Changed
- Moved task `check:models` to `test:models` to keep namespaces tight
- Run rails upgrades for 5.2 so we gret the most out of our setup
- Upgrade Ruby from 2.5.1 to 2.5.3
- Update gems to the latest versions
- Bugfix on support list, now transferred memberships show user's details correctly
- Order displayed membership offers by price, highest to lowest
- Fixed a bug where you could upgrade Adult to Adult memberships after the price increase

### Removed
- Nothing significant in this release

## Tag 1.1.0 - 2019-05-22

Some quality of life improvements for support, and general cleanup with things we learnt from our initial release.

### Added
- Detection of Stripe test keys to change colours on pages to distinguish between production and test systems
- Migrations to correct data corruption on imported timestamps
- Customer stripe ID now recorded and reused from User model going forward
- New rake tasks for your utility belt:
  ```bash
  # Copy over stripe customer details to users with
  bundle exec rake stripe:sync:customers

  # Update historical charge descriptions in stripe and charge comments with
  bundle exec rake stripe:sync:charges

  # Detect invalid records on your systems with
  bundle exec rake test:models
  ```
- CoNZealand images are now served from the project rather than GitHub to consolidate infrastructure
- When purchasing a new membership, if you've got existing memberships you now get linked to the 'Review Memberships'
  section with a helpful message
- Added Policy and Terms of service to CoNZealand pages

### Changed
- URLs for charging a person have been updated to use Purchase for consistency
- Fixed Kansa and Presupport import methods to set "active" correctly on older records
- Charge descriptions in stripe now describe amount owed, type of payment, membership name and number
- Allow database name to be configurable on production builds for cheep staging costs
- Updated most gems in the project including Rails
- Replaced deprecated SASS gem with SASSC
- Redirect to current page on login, puts you on the "new membership" or "review memberships" pages
- New styles added to support page for readability
- Email address added to support page for findability
- Performance improvements for support memberships listing
- Makefile has smarter build targets that create databases and images as needed
- Developer setup steps in README should run out of the box

### Removed
- Nothing significant in this release

## Tag 1.0.0 - 2019-03-29

Initial release of CoNZealand, intended to give people what they had with Kansa, introduce instalments and bring in our
pre supporters.

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
