desc 'Strip spaces from subjects'
task remove_subject_spaces: [:environment] do
  progress = ProgressBar.new(Work.count)
  Work.find_each do |w|
    original_subject = []
    work.subject = work.subject.map do |subject|
      original_subject << subject
      subject.strip
    end
    work.save if work.subject.to_a != original_subject
    progress.increment!
  end
end

desc 'Fixes mp3 facet duplications and properly set to MPEG'
task repair_format_digital: [:environment] do
  progress = ProgressBar.new(Work.count)
  Work.find_each do |w|
    first = w.format_digital&.first
    if first && first&.downcase&.match?('mp3')
      w.format_digital = ['MPEG']
      w.save!
    end
    progress.increment!
  end
end

desc 'reindex collections shallowly'
task collection_index_only: [:environment] do
  progress = ProgressBar.new(Collection.count)

  Collection.find_each do |collection|
    collection.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
    collection.update_index
    progress.increment!
  end
end

desc 'Move location on collection to contributing institution'
task location_to_contributing: [:environment] do
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
      c.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
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

desc 'find works missing from fedora but still in search index'
task find_missing_in_fedora: [:environment] do
  progress = ProgressBar.new(Work.count)
  Work.find_each do |w|
    begin
      progress.increment!
    rescue ActiveFedora::ActiveFedoraError => e
      puts e.message
    end
  end
end
