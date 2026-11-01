# WtwUk

A simple gem to pull cinemas and performances from the [WTW Cinemas website](https://wtwcinemas.co.uk) and spit out useful formatted info.

## Installation

Add this line to your application's Gemfile:

    gem 'wtw_uk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wtw_uk

## Usage

The gem conforms to the API set down in the `cinebase` gem, [andycroll/cinebase](https://github.com/andycroll/cinebase), which provides a lot of useful base vocabulary and repetitive code for this series of cinema focussed gems.

Performance titles are sanitized as much as possible, removing years,
subtitle, preview, autism friendly, Q&A and film club markers, and naming
National Theatre Live, Royal Ballet and Opera and Exhibition on Screen
screenings in full.

No token or setup is needed. WTW's WordPress website runs Jacro's cinema
plugin, with a subsite for each venue. Tickets are sold through TapOS,
behind each venue's own booking pages.

### Cinema

The gem holds WTW's four Cornish venues, keyed by the TapOS site code in
their booking pages: subsites and Jacro cinema ids from the home page,
addresses from each venue's page footer and coordinates from OpenStreetMap.
Cinema methods make no requests.

``` ruby
WtwUk::Cinema.all
#=> [<WtwUk::Cinema ...>, <WtwUk::Cinema ...>, ...]

cinema = WtwUk::Cinema.new('PLATRU')
#=> <WtwUk::Cinema ...>

cinema.adr
#=> {
  street_address:   '69 Lemon Street',
  extended_address: nil,
  locality:         'Truro',
  region:           'Cornwall',
  postal_code:      'TR1 2PN',
  country_name:     'United Kingdom'
}

cinema.brand
#=> 'WTW Cinemas'

cinema.full_name
#=> 'WTW Cinemas Truro'

cinema.id
#=> 'PLATRU'

cinema.latitude
#=> 50.261851

cinema.url
#=> 'https://wtwcinemas.co.uk/truro/'
```

| id | name |
| --- | --- |
| `WTWNEW` | Newquay (Lighthouse Cinema) |
| `FILAUS` | St Austell (White River Cinema) |
| `PLATRU` | Truro (The Plaza) |
| `REGWAD` | Wadebridge (The Regal) |

### Performances

`Performance.at` returns performances for an inclusive range of showing dates,
defaulting to today in London and the following 13 days. The what's on page's
'All Shows' request lists every showtime the venue has on sale, so any range
is one request.

``` ruby
WtwUk::Performance.at('PLATRU', from: Date.today, to: Date.today + 2)
#=> [<WtwUk::Performance ...>, <WtwUk::Performance ...>, ...]

performance = WtwUk::Performance.at('PLATRU').first
#=> <WtwUk::Performance ...>

performance.film_name
#=> 'Heart of the Beast' # from 'Heart of the Beast (with subtitles)'

performance.film_year
#=> nil # from the title, e.g. 1971 for 'The Devils (1971)'

performance.dimension
#=> '2d'

performance.variant
#=> ['senior', 'subtitled']

performance.subtitled?
#=> true

performance.festival
#=> nil

performance.starting_at
#=> 2026-11-12 11:15:00 UTC

performance.booking_url
#=> 'https://wtwcinemas.co.uk/truro/booknow/122882/'

performance.cinema_name
#=> 'Truro'

performance.cinema_id
#=> 'PLATRU'
```

Booking links go to the venue's booking page, which holds the TapOS seat
selection. Showtimes already passed today have no booking link.

Variants come from each showtime's classes and the title: `arts` (event
cinema: theatre, opera, ballet, musicals, concerts and exhibitions), `q&a`,
`relaxed` (autism friendly), `senior` (Silver Screen) and `subtitled`. Many
screenings offer audio description headsets or caption glasses, so neither
is a variant. Laser projection, strobe warnings and ticket offers are not
variants either.

## Tests

```sh
bundle exec rake          # unit tests against fixtures
bundle exec rake live     # live wtwcinemas.co.uk
```

The fixture in `test/fixtures` is Truro's programme, trimmed to a few films
with shortened descriptions. `test/support/api_shapes.rb` describes the
markup the gem reads. The unit suite checks the fixture against it and the
live suite checks every venue's real programme, held only in memory, along
with the venue list and each venue's TapOS code. When the markup changes,
update the shape first, then the fixture.

## Releasing

Bump the version, merge, then run the **Release Gem** workflow in GitHub
Actions. It runs the tests, tags the version and publishes the gem through
RubyGems trusted publishing.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
