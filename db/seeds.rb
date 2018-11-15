# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.where(email: 'rob@notch8.com').first_or_create do |f|
  f.password = 'testing123'
  f.admin_area = true
end

if Rails.env.development?
  User.where(email: 'archivist1@example.com').first_or_create do |f|
    f.password = 'Ka55ttp72'
  end
end

User.where(email: 'acarter@atla.com').first_or_create do |f|
  f.password = 'Ka55ttp72'
  f.admin_area = true
end

User.where(email: 'ckarpinski@atla.com').first_or_create do |f|
  f.password = 'Ka55ttp72'
  f.admin_area = true
end

User.where(email: 'jbutler@atla.com').first_or_create do |f|
  f.password = 'Ka55ttp72'
  f.admin_area = true
end

#Rake::Task['hyrax:default_collection_types:create'].invoke
#Rake::Task['hyrax:default_admin_set:create'].invoke
Rake::Task['sufia:default_admin_set:create'].invoke
Rake::Task['curation_concerns:workflow:load'].invoke
Rake::Task['sufia:migrate:move_all_works_to_admin_set']
# Rake::Task['import:import_ptc_oia'].invoke('rob@notch8.com', 'true') if Rails.env.development?

if Rails.env.development?
  Harvester.create!(
    name: "Princeton Theological Commons - Benson",
    admin_set_id: "admin_set/default",
    user_id: 1,
    base_url: "http://commons.ptsem.edu/api/oai-pmh",
    external_set_id: "collection:Benson",
    institution_name: "Princeton Theological Seminary",
    frequency: "PT0S",
    limit: 50,
    importer_name: "OAI::PTC::Importer",
    right_statement: "http://rightsstatements.org/vocab/CNE/1.0/",
    thumbnail_url: "http://commons.ptsem.edu/?cover=<%= identifier.split('/').last %>",
    metadata_prefix: 'oai_dc'
  )
end

ActiveFedora::Base.reindex_everything if Rails.env.development?
