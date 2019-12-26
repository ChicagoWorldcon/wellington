# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased](https://gitlab.com/worldcon/2020-wellington/compare/2.1.0...master)

### Added
- Added Hugos state configuration [!89](https://gitlab.com/worldcon/2020-wellington/merge_requests/89).
  Please set these values in your .env on all environments:
  ```
  # Times when parts of the members area will become active
  HUGO_NOMINATIONS_OPEN_AT="2019-12-31T23:59:00-08:00"
  HUGO_VOTING_OPEN_AT="2020-03-13T11:59:00-08:00"
  HUGO_CLOSED_AT="2020-08-02T12:00:00+13:00"
  ```
- Created seeds for Dublin memberships and Hugo awards to automatically show up with
  new Development or Production seeds
  [!137](https://gitlab.com/worldcon/2020-wellington/merge_requests/137)
  and [!89](https://gitlab.com/worldcon/2020-wellington/merge_requests/89).
  Migrate existing instances with
  ```bash
  make bash
  bin/rake db:seed:conzealand:production_dublin
  bin/rake db:seed:conzealand:production_hugo
  ```
- Links to Hugo and Retro Hugo are now present on the membership cards
  [!89](https://gitlab.com/worldcon/2020-wellington/merge_requests/89).
- Memberships now have a flag to say if they can site select
  [!136](https://gitlab.com/worldcon/2020-wellington/merge_requests/136)
- Dublin memberships importer built from Tammy's unduplicated memberships list
  [!137](https://gitlab.com/worldcon/2020-wellington/merge_requests/137)
  ```bash
  make bash
  DUBLIN_SRC="unduplicated members-Table 1.csv" bin/rake import:dublin
  ```
- People who have paid an instalment which covers a Supporting membership can nominate in Hugo
  [!138](https://gitlab.com/worldcon/2020-wellington/merge_requests/138)
- You can now adjust instalment minimum payment and payment step amounts by setting them in your environment
  [!138](https://gitlab.com/worldcon/2020-wellington/merge_requests/138)
  ```bash
  INSTALMENT_MIN_PAYMENT_CENTS=7500
  INSTALMENT_PAYMENT_STEP_CENTS=5000
  ```
- Dublin and CoNZealand nomination memberships now have mailers to tell them when
  Nominations are open.
  [!137](https://gitlab.com/worldcon/2020-wellington/merge_requests/137)
  You can run these from Rails Console with:
  ```ruby
  dublin_users = User.joins(reservations: :membership).where(memberships: {name: :dublin_2019});
  dublin_users.distinct.find_each do |user|
    MembershipMailer.nominations_notice_dublin(user: user).deliver_now
  end;

  conzealand_users = User.joins(reservations: :membership).merge(Membership.can_nominate).where.not(id: dublin_users);
  conzealand_users.distinct.find_each do |user|
    MembershipMailer.nominations_notice_conzealand(user: user).deliver_now
  end;
  ```

### Changed
- We've renamed "Review Memberships" to "My Memberships" in the menu to reduce confusion
  [!89](https://gitlab.com/worldcon/2020-wellington/merge_requests/89)
- To reduce CSS bugs, colour rotation when you have test keys for dev/staging only affect the logo
  [!89](https://gitlab.com/worldcon/2020-wellington/merge_requests/89)
- Viewport is set explicitly on CoNZealand pages based on the
  [Bootstrap guidelines](https://getbootstrap.com/docs/4.3/getting-started/introduction/#responsive-meta-tag)
  [!89](https://gitlab.com/worldcon/2020-wellington/merge_requests/89)
- Developers can now Napalm from an interactive rebase
  [!89](https://gitlab.com/worldcon/2020-wellington/merge_requests/89)
- CoNZealand development DB seeds are now based on Prod to reduce duplication of effort
  [!89](https://gitlab.com/worldcon/2020-wellington/merge_requests/89)
- Securitiy patch puma against a Denial of Service vunerability
  [CVE-2019-16770](https://nvd.nist.gov/vuln/detail/CVE-2019-16770)
  [!129](https://gitlab.com/worldcon/2020-wellington/merge_requests/129)
- Reconfigure Money rounding to round up on 0.5 cents to
  match [stripe's decimal rounding](https://stripe.com/docs/billing/subscriptions/decimal-amounts#rounding)
  [!134](https://gitlab.com/worldcon/2020-wellington/merge_requests/134)

### Removed
- Moved yarn's OS dependent integrity check from application bootstrap to CI
  [!133](https://gitlab.com/worldcon/2020-wellington/merge_requests/133)


## [Tag 2.1.0 - 2019-11-22](https://gitlab.com/worldcon/2020-wellington/compare/2.0.0...2.1.0)

### Added
- Added easy methods for checking licences in depenedencies
  [!117](https://gitlab.com/worldcon/2020-wellington/merge_requests/117)
  ```bash
  bundle exec rake gem:licenses  # check Ruby
  yarn licenses list             # check JavaScript
  ```
- Seeding a development database creates a support user by default
  [!118](https://gitlab.com/worldcon/2020-wellington/merge_requests/118)
- New make target to reset database and javascript dependencies quickly
  [!118](https://gitlab.com/worldcon/2020-wellington/merge_requests/118)
  ```bash
  make reset start
  # faster than `make clean`
  ```
- Script running updates and pushing up the lock files
  [!123](https://gitlab.com/worldcon/2020-wellington/merge_requests/123)
  ```bash
  rake dev:update
  ```

### Changed
- Allow people to append/prepend whitespace to their email addess
  [!116](https://gitlab.com/worldcon/2020-wellington/merge_requests/116)
- Reduced the size of our install by moving docker base from debian to alpine
  [!102](https://gitlab.com/worldcon/2020-wellington/merge_requests/102)
- Update project dependencies
  [!123](https://gitlab.com/worldcon/2020-wellington/merge_requests/123)
- We now use structure.sql instead of schema.rb for database revision tracking
  [!122](https://gitlab.com/worldcon/2020-wellington/merge_requests/122)
- Securitiy patch nokogiri against input validation vulnerability
  [CVE-2019-16892](https://nvd.nist.gov/vuln/detail/CVE-2019-13117)
- Securitiy patch brakeman against local privilege escalation vulnerability
  [CVE-2019-18409](https://nvd.nist.gov/vuln/detail/CVE-2019-18409)

### Removed
- Nothing significant in this release


## [Tag 2.0.0 - 2019-10-06](https://gitlab.com/worldcon/2020-wellington/compare/1.6.0...2.0.0)

### Added
- Rails 6 backards incompatable defaults are now enabled
  [!100](https://gitlab.com/worldcon/2020-wellington/merge_requests/100)
- We now use Webpacker to manage Sass assets and JavaScript compilation
  [!99](https://gitlab.com/worldcon/2020-wellington/merge_requests/100)
- JavaScript dependencies are now audited on CI
  [!100](https://gitlab.com/worldcon/2020-wellington/merge_requests/100)
- JavaScript linting is now enforced in CI
  [!100](https://gitlab.com/worldcon/2020-wellington/merge_requests/100)

### Changed
- Nothing significant in this release

### Removed
- EMAIL_PAYMENTS has been removed. Please set MEMBER_SERVICES_EMAIL in .env everywhere.
  [!100](https://gitlab.com/worldcon/2020-wellington/merge_requests/100)


## [Tag 1.6.0 - 2019-10-04](https://gitlab.com/worldcon/2020-wellington/compare/1.5.1...1.6.0)

### Added
- Nothing significant in this release

### Changed
- Upgrade Rails from 5.2 to 6.0 [!99](https://gitlab.com/worldcon/2020-wellington/merge_requests/99)
- Upgraded project gems [!99](https://gitlab.com/worldcon/2020-wellington/merge_requests/99)
- Fixed a bug in development seeds where $0 memberships have a charge
  [!99](https://gitlab.com/worldcon/2020-wellington/merge_requests/99)
- Fix typo in transfer mailer, affect vs effect
  [!100](https://gitlab.com/worldcon/2020-wellington/merge_requests/111)
- Fix vulnerability in rubyzip "zipbombs"
  [!112](https://gitlab.com/worldcon/2020-wellington/merge_requests/112),
  patches against [CVE-2019-16892](https://nvd.nist.gov/vuln/detail/CVE-2019-16892)
- Bump ruby from 2.6.3 to 2.6.5
  [!114](https://gitlab.com/worldcon/2020-wellington/merge_requests/101),
  patches against
  [CVE-2019-16201](https://nvd.nist.gov/vuln/detail/CVE-2019-16201),
  [CVE-2019-16254](https://nvd.nist.gov/vuln/detail/CVE-2019-16254),
  [CVE-2019-15845](https://nvd.nist.gov/vuln/detail/CVE-2019-15845),
  and [CVE-2019-16255](https://nvd.nist.gov/vuln/detail/CVE-2019-16255)

### Removed
- Removed dependency on makerb gem to reduce risk and use more core rails features.
  To maintain both html and text emails you now need to maintain two templates
  [!99](https://gitlab.com/worldcon/2020-wellington/merge_requests/99)


## [Tag 1.5.1 - 2019-09-10](https://gitlab.com/worldcon/2020-wellington/compare/1.5.0...1.5.1)

### Added
- Nothing significant in this release

### Changed
- Last minute security patch for Devise that came up just after release, patches
  [CVE-2019-16109](https://nvd.nist.gov/vuln/detail/CVE-2019-16109)

### Removed
- Nothing significant in this release


## [Tag 1.5.0 - 2019-09-10](https://gitlab.com/worldcon/2020-wellington/compare/1.4.1...1.5.0)

### Added
- Kiosk mode, now we can get people to record their details to reduce time handling data entry
  [!93](https://gitlab.com/worldcon/2020-wellington/merge_requests/93)

### Changed
- Bugfix, users can now set their title on their membership [!92](https://gitlab.com/worldcon/2020-wellington/merge_requests/92)
- Assets are now coppied within the project for offline support [!94](https://gitlab.com/worldcon/2020-wellington/merge_requests/94)
- System emails are now configured globally from .env with MEMBER_SERVICES_EMAIL.
  [!93](https://gitlab.com/worldcon/2020-wellington/merge_requests/93). Please replace EMAIL_PAYMENTS this in your .env:
  ```
  MEMBER_SERVICES_EMAIL=registration@conzealand.nz
  ```
- Seeds are installed using seedbank
  [!95](https://gitlab.com/worldcon/2020-wellington/merge_requests/95)
- Copyright checks don't require you to keep your author in all files authored, only enforces Apache boilerplate going
  forward
  [!101](https://gitlab.com/worldcon/2020-wellington/merge_requests/101)
- Appplied security patches for
  [CVE-2015-7580](https://nvd.nist.gov/vuln/detail/CVE-2015-7580),
  [CVE-2015-7579](https://nvd.nist.gov/vuln/detail/CVE-2015-7579) and
  [CVE-2015-7578](https://nvd.nist.gov/vuln/detail/CVE-2015-7578) -
  [!104](https://gitlab.com/worldcon/2020-wellington/merge_requests/104)

### Removed
- EMAIL_PAYMENTS has been deprecated and will be removed in the next few releases.
  [!93](https://gitlab.com/worldcon/2020-wellington/merge_requests/93)


## [Tag 1.4.1 - 2019-07-22](https://gitlab.com/worldcon/2020-wellington/compare/1.4.0...1.4.1)

Hotpatch, in 1.4.0 we regressed the payments mailer for instalments which no longer send. This patch release fixes that
mailer.

### Added
- Nothing significant in this release

### Changed
- Fixed regression, instalments mailer now sends happily [!91](https://gitlab.com/worldcon/2020-wellington/merge_requests/91)

### Removed
- Nothing significant in this release


## [Tag 1.4.0 - 2019-07-22](https://gitlab.com/worldcon/2020-wellington/compare/1.3.0...1.4.0)

This release has a bit of everything. We're making life better for other cons with support for multi currency, our
support staff who have more fatures for adjusting memberships, and our developers have better seeded data for something
that feels better right out of the box.

### Added
- Added brakeman, ruby-audit, and bundler-audit vulnerability scanners to the build process and `make test`
  [!85](https://gitlab.com/worldcon/2020-wellington/merge_requests/85)
- Configurable currency, add STRIPE_CURRENCY to your .env and all prices are now in that currency
  [!70](https://gitlab.com/worldcon/2020-wellington/merge_requests/70)
- Support can set membership to any level, including past memberships
  [!87](https://gitlab.com/worldcon/2020-wellington/merge_requests/87)
- Support can credit memberships with cash, allows support to create and credit memberships
  [!87](https://gitlab.com/worldcon/2020-wellington/merge_requests/87)
- User notes are now exposed on the reservation show screen
  [!87](https://gitlab.com/worldcon/2020-wellington/merge_requests/87)
- Upgrades and membership changes are now shown to our members
  [!87](https://gitlab.com/worldcon/2020-wellington/merge_requests/87)

### Changed
- Added unique constraint to membership number data model
  [!70](https://gitlab.com/worldcon/2020-wellington/merge_requests/70). Please check and correct duplicates with this:
  ```
  Reservation.having("count(membership_number) > 1").group(:membership_number).pluck(:membership_number)
  ```
- Upgraded gems to the latest versions [!83](https://gitlab.com/worldcon/2020-wellington/merge_requests/83)
- Generated memberships in testing now have charges
  [!84](https://gitlab.com/worldcon/2020-wellington/merge_requests/84)
  and [!86](https://gitlab.com/worldcon/2020-wellington/merge_requests/86)
- Support can now transfer memberships that are in instalment
  [!88](https://gitlab.com/worldcon/2020-wellington/merge_requests/88)

### Removed
- Nothing significant in this release


## [Tag 1.3.0 - 2019-06-19](https://gitlab.com/worldcon/2020-wellington/compare/1.2.0...1.3.0)

### Added
- Purchase flow changed to let you select a membership before signing in [!73](https://gitlab.com/worldcon/2020-wellington/merge_requests/73)
- Prominant prices, membership rights and buttons on all memberships [!73](https://gitlab.com/worldcon/2020-wellington/merge_requests/73)

### Changed
- Upgraded gems to the latest versions [!76](https://gitlab.com/worldcon/2020-wellington/merge_requests/76)
- Renamed Purchase to Reservation to match the domain more closely
- Fixed charge descriptions in Stripe and in Charge comments
  [!80](https://gitlab.com/worldcon/2020-wellington/merge_requests/80).
  Cleanup retrospectively with this rake task post release:
  ```bash
  bundle exec rake stripe:sync:charges
  ```

### Removed
- Paths to resources have changed, /purchases have moved to /reservations


## [Tag 1.2.0 - 2019-06-08](https://gitlab.com/worldcon/2020-wellington/compare/1.1.0...1.2.0)

Upgraded Ruby and Rails, and support function for transferring memberships.

### Added
- Turned on [Content Security Policy (CSP)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy)
  for the site for security hygiene
- Support can now transfer memberships between users from a user's detail form

### Changed
- Moved task `check:models` to `test:models` to keep namespaces tight
- Run rails upgrades for 5.2 so we get the most out of our setup
- Upgrade Ruby from 2.5.1 to 2.5.3
- Update gems to the latest versions
- Bugfix on support list, now transferred memberships show user's details correctly
- Order displayed membership offers by price, highest to lowest
- Fixed a bug where you could upgrade Adult to Adult memberships after the price increase

### Removed
- Nothing significant in this release


## [Tag 1.1.0 - 2019-05-22](https://gitlab.com/worldcon/2020-wellington/compare/1.0.0...1.1.0)

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


## [Tag 1.0.0 - 2019-03-29](https://gitlab.com/worldcon/2020-wellington/compare/af2b82ad46c69485c33de3ba317d95cedb5a2f5c...1.0.0)

Initial release of CoNZealand, intended to give people what they had with Kansa, introduce instalments and bring in our
pre supporters.

### Added
- Basic forms for purchasing memberships based on CoNZealand paper forms
- Payments, including pay by instalment
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
