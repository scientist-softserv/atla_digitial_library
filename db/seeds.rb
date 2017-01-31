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

User.where(email: 'archivist1@example.com').first_or_create do |f|
  f.password = 'testing123'
end 

User.where(email: 'acarter@atla.com').first_or_create do |f|
  f.password = 'testing123'
  f.admin_area = true
end 

