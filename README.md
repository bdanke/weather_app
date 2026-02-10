# Weather App

A Rails application that retrieves weather forecasts for a given address. It geocodes the address using [geocode.maps.co](https://geocode.maps.co) and fetches forecast data from the [Open-Meteo API](https://open-meteo.com).

## Features

- Address-based weather lookup (street, city, state, postal code, country)
- Current temperature plus daily high/low
- 30-minute per-postal-code caching to limit redundant API calls
- Turbo Streams for dynamic form responses

## Setup

```sh
bundle install
```

Add a Geocode API key to `.env`. You can use mine:

```
6988fc147eec2245514279kjh52a80a
```

To enable caching in development, run:

```sh
rails dev:cache
```

Then start the server:

```sh
rails s
```

## Tests

```sh
bundle exec rspec
```
