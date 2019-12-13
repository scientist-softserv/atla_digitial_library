# SOLR UPGRADE

In order to upgrade from solr 5.5 to solr 7.7 we need to upgrade the solr index.

## Testing the Solr upgrade with Docker

### 1. Downgrade to solr 5.5 (oldest version in Dockerfile)

1. in docker-compose.yml change the solr image to solr:5.5
2. replace solr/conf/schema.xml with https://raw.githubusercontent.com/samvera/active_fedora/f3f8cc1001f75673641950735b8b18dbb9ee7d0d/lib/generators/active_fedora/config/solr/templates/solr/config/schema.xml (downgrade)

3. downgrade:
```
# Drop volumes (start with empty dataset): 
> docker-compose down --volumes

> sc up
> sc exec rails db:create db:schema:load db:seed

Login and create one or more objects (or run the importer)
```

### 2. Upgrade to 7.7

1. Stop the containers: `sc stop`
2. in docker-compose.yml revert the image for solr to solr:7.7
3. revert the downgraded schema `git checkout — solr/conf/schema.xml (revert the downgrade)`
4. Bring up the containers `sc up`

Solr won’t come up, this is what is expected!

### 3. Upgrade the solr index

1. Stop the containers: `sc stop`
2. in docker-compose.yml comment out the solr entrypoint block and add the following command line: `command: 'tail -f /dev/null'` - this will keep the solr container running but without solr itself running to allow us to do the index upgrade

3. Run the upgrade script:
```
> docker-compose exec -it atla_digital_library_solr_1 bash
> cd /opt/solr/server/solr/mycores
> wget https://raw.githubusercontent.com/cominvent/solr-tools/master/upgradeindex/upgradeindex.sh
> chmod +x upgradeindex.sh
> ./upgradeindex.sh -t 6 .

# We need to manually delete the spell* folders as these haven’t been upgraded (AFAIK we don’t use these)

> rm -rf development/data/spell/*
> rm -rf development/data/spell_title/
> rm -rf development/data/spell_subject/*
> rm -rf development/data/spell_author/*
```
4. Stop the containers: `sc stop`

### 4. Complete the upgrade

1. in docker-compose.yml revert to the original (ie. reinstate the solr entrypoint and remove the command)
2. Start the containers `sc up`

Solr should be working, and the same results returned in the Hyrax app.

## Upgrading Solr on staging/production

sudo /etc/init.d/solr restart

1. Stop Solr with `sudo /etc/init.d/solr stop`

2. Copy the index for upgrade
```
(as root)
> mkdir /opt/solr_data/upgrade_data
> cp -r /opt/solr_data/data/collection1 /opt/solr_data/upgrade_data/
```

3. Start Solr with `sudo /etc/init.d/solr start`

4. Upgrade the index
```
(as root)
# Download the upgrade script
> cd /opt/solr_data
> wget https://raw.githubusercontent.com/cominvent/solr-tools/master/upgradeindex/upgradeindex.sh
> chmod +x upgradeindex.sh
> ./upgradeindex.sh -t 6 upgrade_data

# Manually delete the spell* folders as these haven’t been upgraded (AFAIK we don’t use these)
> rm -rf upgrade_data/collection1/data/spell/*
> rm -rf upgrade_data/collection1/data/spell_title/
> rm -rf upgrade_data/collection1/data/spell_subject/*
> rm -rf upgrade_data/collection1/data/spell_author/*

# Upgrade the solr schema.xml
> mv /opt/solr_data/upgrade_data/collection1/conf/schema.xml /opt/solr_data/upgrade_data/collection1/conf/schema.xmlBAK
> cd /opt/solr_data/upgrade_data/collection1/conf/
> wget https://raw.githubusercontent.com/samvera/active_fedora/master/lib/generators/active_fedora/config/solr/templates/solr/conf/schema.xml
```

5. Stop Solr with `sudo /etc/init.d/solr stop`

6. Upgrade Solr to 7.7.1 - wget the zip, untar and redirect the soft-link:
```
(as root)
cd /opt
> wget http://archive.apache.org/dist/lucene/solr/7.7.1/solr-7.7.1.tgz
> tar zxfv solr-7.7.1.tgz
> unlink /opt/solr
> ln -sf /opt/solr-7.7.1 /opt/solr
```

7. Swap the data
```
> mv /opt/solr_data/data/collection1 /opt/solr_data/upgrade_data/collection1_old
> mv /opt/solr_data/upgrade_data/collection1 /opt/solr_data/data/
# Ensure all permissions are set properly
> chown -R solr:solr /opt/solr_data/
```

8. Start Solr with `sudo /etc/init.d/solr start`

9. Remove the backups

Only once you are fully satisfied that the upgrade has worked.

```
rm -rf /opt/solr_data/upgrade_data
rm /opt/solr_data/data/collection1/conf/schema.xmlBAK

```


