# ATLA Digital Library

ATLA staff use this repository as their digital library.

## Versions

  - Ruby 2.5.1
  - Rails 5.1.6
  - Hyrax 2.3.3

## Development Install

```
bundle; bundle exec rake hydra:server
```

The app should now be available at http://localhost:3000.

## Testing

On the first run you will need to do: `bundle exec rake db:migrate RAILS_ENV=test`

Then run the test suite with:

```
bundle; bundle exec rake hydra:test_server
bundle exec rake spec
```
