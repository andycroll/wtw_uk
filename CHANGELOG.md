# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.0.1] - 2026-11-02

### Changed
- Requests and London times use cinebase 5.8's `Cinebase::Http` and `Cinebase::London`.
- HTTP errors read "HTTP error 500 from wtwcinemas.co.uk" instead of "WTW Cinemas HTTP error 500".

### Removed
- `WtwUk::Performance::TIME_ZONE`, now unused.

## [1.0.0] - 2026-11-02

### Added
- `WtwUk::Cinema.all` and `WtwUk::Cinema.new(id)` for WTW Cinemas' four venues, keyed by TapOS site code, with addresses from each venue's page footer and coordinates from OpenStreetMap.
- `WtwUk::Performance.at(id, from:, to:)`, from the what's on page's 'All Shows' request, which holds every advertised date in one request, with booking links, variants from showtime classes and titles, film years and festivals from titles.
- Fixtures trimmed from live pages, a live shape test that checks real responses without storing them, and GitHub Actions CI and release workflows.
