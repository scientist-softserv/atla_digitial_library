# Atla Digital Library

Atla staff use this repository as their digital library.

## Versions

  - Ruby 2.5.3
  - Rails 5.1.6
  - Hyrax 2.3.3

## Development Install

This project has a containerized developement environment managed with with `stack_car`.

```sh
git clone git@gitlab.com:notch8/atla_digital_library.git
cd atla_digital_library
sc up
```

The app should now be available at http://localhost:3000.

On the first run, you may need to run some setup:

* run database migrations
* seed the database with colleciton types and the default admin set

```sh
sc be rake db:schema:load db:migrate db:seed
```
Once these are done, stop and start the containers to ensure dj is picking up the database migration.

## Testing

On the first run you will need to do: `bundle exec rake db:migrate RAILS_ENV=test`

Then run the test suite with:

```
bundle; bundle exec rake hydra:test_server
bundle exec rake spec
```

## Troubleshooting
### Ldp::Conflict

If an `Ldp::Conflict, "Can't call create on an existing resource"` error is encountered when attempting to create a Work, Collection, etc., run the following command in a rails console:

```
[::Noid::Rails::Service.new.minter.mint, ::Noid::Rails::Service.new.minter.mint]
```

Upon resubmission of the form, the resource should be created successfully.

This is currently a known bug in Hyrax. See here for more details: https://github.com/samvera/hyrax/issues/3128

### Statistics Not Updating

Statistics can be updated manually by running `UpdateStatisticalDataJob.perform_later` in the rails console.

Once run, the job will automatically schedule itself to run again in the future.

# Backups
## Backup Tools

We use the [backup gem](http://backup.github.io/backup/v4/) to perform our backups. It has a lot of built in tools for dealing with most of the stack and runs very dependably. An email is sent at the end of each daily backup. This is set as a cron job on the Tomcat server and configured via the `ops/roles/notch8.backups` role.

## What is Backed Up
### Hyrax

For Hyrax we backup the database that Hyrax uses directly (to store users and session info), along with the database that Fedora uses. We back up all config files and derivatives (to speed restoration). Code is already in Gitlab and thus does not need separate backup. The Solr indexes are not backed up currently as they can be regenerated and are large.

## Backup Schedule

Currently backups are taken nightly. This can be scaled up or down easily by editing the cron jobs on the servers.


# Restore Procedure

Backups are encrypted and stored in S3. To restore backups, first download the correct backup files from S3.  At that point the backup needs to be decrypted as per [instructions here](http://backup.github.io/backup/v4/encryptor-openssl/).  Password is found in the secure env files under `backup_password`. After the tar file is decrypted Postgresql restore is done via the psql command and uploaded files can be copied back in to place manually. At that point Fedora, Solr and Passenger can all be restarted. 
