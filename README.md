# ATLA Digital Library

ATLA staff use this repository as their digital library.

## Versions

  - Ruby 2.5.3
  - Rails 5.1.6
  - Hyrax 2.3.3

## Development Install

This project is has a containerized developement environment managed with with `stack_car`.

```sh
git clone git@gitlab.com:notch8/atla_digital_library.git
cd atla_digital_library
sc up
```

The app should now be available at http://localhost:3000.

On the first run, you may need to do setup Solr and run database migrations:

```sh
sc exec -s solr bin/solr create -c development -d /opt/config`
sc be rake db:schema:load db:migrate
```

## Testing

On the first run you will need to do: `bundle exec rake db:migrate RAILS_ENV=test`

Then run the test suite with:

```
bundle; bundle exec rake hydra:test_server
bundle exec rake spec
```
