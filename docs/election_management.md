# Managing Hugo Elections in Wellington

As of this date (2022-04-20) there is no administration interface, so this is a description of the backend data management operations you'll need to do in order to administer an election.

## Create the election itself

Each election is anchored to a named and keyed `Election` entity. That election has two characteristics that are relevant:

1. `name`: This is the name that will be reported in the UI. Note that this needs to not include "Awards" as a suffix, since Wellington currently assumes that to be the case and appends it (FIXME: this is a bug). Examples:

- `Hugo`
- `Retro Hugo`

2. `i18n_key`: This is the key that will be used to look up descriptive text in the `config/locales/<convention>/en.yml` files, specifically in the `en:rights:<i18n_key>` map.

## Create the categories

This step takes place before nominations. Each category needs to be created as a `Category` model attached to the election. You will create one `Category` for each election/category pair (so, "Best Novel" must be created twice, once for Hugo Awards and once for Retro Hugo Awards, if your convention is doing both). The category must have:

1. `name` - the short name of the category. This will be used as the vote submission button text, and in headings.
2. `description` - the long description of the content. This can be in markdown format, and will be rendered to HTML when displayed.
3. `field_1`, `field_2`, `field_3` -- The fields to collect. Set them to readable names, or `nil` if the field is not needed.
4. `order` - the order the category should appear on the ballot.

## Example script to set up nominations

```ruby
year = "2021"
election = Election.create(name: "Hugo")

Category.create!(name: "Best Novel",
                 description: "A science fiction or fantasy story of 40,000 words or more, published for the first time in #{year}.",
                 field_1: "Title",
                 field_2: "Author",
                 field_3: nil,
                 election: election,
                 order: 1)
Category.create!(name: "Best Novella",
                 description: "A science fiction or fantasy story between 17,500 and 40,000 words, which appeared for the first time in #{year}.",
                 field_1: "Title",
                 field_2: "Author",
                 field_3: nil,
                 election: election,
                 order: 2)
```

## Finalists

Once nominations are completed, finalists are set for each category by providing a `Finalist` object for each one. Finalists are simple, and only have two required fields.

1. `description` - the line that will appear on the ballot for the finalist.
2. `category` - a reference to the category for which this entry is a finalist

## Example finalist creation

```ruby
election = Election.find_by_name("Hugo")
category = election.categories.find_by_name("Best Novel")
Finalist.create!(description: "A Desolation Called Peace, by Arkady Martine (Tor)", category: category)
Finalist.create!(
  description: "The Galaxy, and the Ground Within, by Becky Chambers (Harper Voyager / Hodder & Stoughton)", category: category
)
Finalist.create!(description: "Light From Uncommon Stars, by Ryka Aoki (Tor)", category: category)
Finalist.create!(description: "A Master of Djinn, by P. Djèlí Clark (Tordotcom / Orbit UK)", category: category)
Finalist.create!(description: "Project Hail Mary, by Andy Weir (Ballantine / Del Rey)", category: category)
Finalist.create!(description: "She Who Became the Sun, by Shelley Parker-Chan (Tor / Mantle)", category: category)
```

# Opening Nominations

Nomination times are controlled by two environment variables:

`HUGO_NOMINATIONS_OPEN_AT`
`HUGO_NOMINATIONS_CLOSE_AT`

These should be set to ISO8601 time stamps with time zone offsets.

# Opening Voting

Voting times are controlled by two environment variables:

`HUGO_VOTING_OPEN_AT`
`HUGO_CLOSED_AT`

... don't ask :/

These should be set to ISO8601 time stamps with time zone offsets.
