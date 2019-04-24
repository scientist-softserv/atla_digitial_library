class AssignLocationValuesToContributingInstitutionOnAllCollections < ActiveRecord::Migration[5.1]
  def up
    puts "Assigning all Collection's :contributing_institution attributes"
    puts "~~to :based_near (Location) values, then clear :based_near values:"

    collections_missing_location = []

    Collection.all.each do |c|
      if c.contributing_institution.present?
        puts ">>> Skipping #{c.id} :contributing_institution already exists => [#{c.contributing_institution.first}]"
        next
      end

      if c.based_near.present?
        puts ">>> #{c.id} :contributing_institution value changed from [#{c.contributing_institution.first}] => [#{c.based_near.first}]"
        c.contributing_institution = c.based_near
        c.based_near = []
        c.save!
      else
        collections_missing_location << c
      end
    end

    if collections_missing_location.any?
      puts "\n"
      puts "!!!WARNING!!! Some Collections were missing :based_near (Location) values! This"
      puts "~~means that they didn't have a Contributing Institution set. Their id's follow:"
      collections_missing_location.each do |cml|
        puts "<<< #{cml.id} (current value: :contributing_institution => [#{cml.contributing_institution.first}])"
      end
    end
  end

  def down
  end
end
