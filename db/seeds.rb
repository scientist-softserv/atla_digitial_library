# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.where(email: 'rob@notch8.com').first_or_create do |f|
  f.password = 'testing123'
end

if Rails.env.development?
  User.where(email: 'archivist1@example.com').first_or_create do |f|
    f.password = 'testing123'
  end
end

User.where(email: 'acarter@atla.com').first_or_create do |f|
  f.password = 'testing123'
end

User.where(email: 'ckarpinski@atla.com').first_or_create do |f|
  f.password = 'testing123'
end
