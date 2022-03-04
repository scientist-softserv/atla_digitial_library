# coding: utf-8
namespace :cdri do
  desc 'woodcuts-and-metal-engravings-from-16th-19th-century-publications fixes'
  task wood: [:environment] do
    col = Collection.where(slug: 'woodcuts-and-metal-engravings-from-16th-19th-century-publications').first
    raise 'collection not found' unless col.present?

    progress = ProgressBar.create(format: "%t %c of %C %a %B %p%%", total: ActiveFedora::Base.where(member_of_collection_ids_ssim: col.id, has_model_ssim: ['Work']).count)
    errors = []
    ActiveFedora::Base.where(member_of_collection_ids_ssim: col.id, has_model_ssim: ['Work']).each do |work|
      begin
        #Remove “Place” value
        #Add Format (Digital): JPEG
        #Add Type: Still Image
        work.place = nil
        work.format_digital = ['JPEG']
        work.types = ['Still Image']
        work.save!
      rescue => e
        errors << [work, e]
      end
      progress.increment
    end
    if errors.present?
      $stderr.puts "-- ERRORS REPORTED"
      $stderr.puts "#{work.id} - #{e.message}\n#{e.backtrace[0..6]}"
    end
  end

  desc 'postcards-of-unitarian-and-universalist-church-buildings fixes'
  task postcards_unitarian: [:environment] do
    col = Collection.where(slug: 'postcards-of-unitarian-and-universalist-church-buildings').first
    raise 'collection not found' unless col.present?

    progress = ProgressBar.create(format: "%t %c of %C %a %B %p%%", total: ActiveFedora::Base.where(member_of_collection_ids_ssim: col.id, has_model_ssim: ['Work']).count)
    errors = []
    ActiveFedora::Base.where(member_of_collection_ids_ssim: col.id, has_model_ssim: ['Work']).each do |work|
      begin
        # Correct Contributing Institution field to be: Andover-Harvard Theological Library
        # Add Format (Digital): JPEG
        # Add Type: Still Image
        # Add Format (Original): Postcards
        work.contributing_institution = ['Andover-Harvard Theological Library']
        work.format_digital = ['JPEG']
        work.types = ['Still Image']
        work.format_original = ['Postcards']
        work.save!
      rescue => e
        errors << [work, e]
      end
      progress.increment
    end
    if errors.present?
      $stderr.puts "-- ERRORS REPORTED"
      $stderr.puts "#{work.id} - #{e.message}\n#{e.backtrace[0..6]}"
    end
  end

  desc 'engravings-from-the-richard-c-kessler-reformation-collection fixes'
  task engravings: [:environment] do
    col = Collection.where(slug: 'engravings-from-the-richard-c-kessler-reformation-collection').first
    raise 'collection not found' unless col.present?

    progress = ProgressBar.create(format: "%t %c of %C %a %B %p%%", total: ActiveFedora::Base.where(member_of_collection_ids_ssim: col.id, has_model_ssim: ['Work']).count)
    errors = []
    ActiveFedora::Base.where(member_of_collection_ids_ssim: col.id, has_model_ssim: ['Work']).each do |work|
      begin
        # Correct Contributing Institution to not have comma at end: Pitts Theology Library
        # Add Format (Digital): JPEG
        # Add Type: Still Image
        work.contributing_institution = ['Pitts Theology Library']
        work.format_digital = ['JPEG']
        work.types = ['Still Image']
        work.save!
      rescue => e
        errors << [work, e]
      end
      progress.increment
    end
    if errors.present?
      $stderr.puts "-- ERRORS REPORTED"
      $stderr.puts "#{work.id} - #{e.message}\n#{e.backtrace[0..6]}"
    end
  end

  desc 'postcards-of-new-england-congregational-and-baptist-churches fixes'
  task postcards_new_england: [:environment] do
    col = Collection.where(slug: 'postcards-of-new-england-congregational-and-baptist-churches').first
    raise 'collection not found' unless col.present?

    progress = ProgressBar.create(format: "%t %c of %C %a %B %p%%", total: ActiveFedora::Base.where(member_of_collection_ids_ssim: col.id, has_model_ssim: ['Work']).count)
    errors = []
    ActiveFedora::Base.where(member_of_collection_ids_ssim: col.id, has_model_ssim: ['Work']).each do |work|
      begin
        # Remove trailing period from subject fields (titles end in abbreviation so dont apply)
        # Correct Contributing Institution field to be: Andover Newton Theological School Franklin Trask Library
        # Add Format (Digital): JPEG
        # Add Type: Still Image
        # Add Format (Original): Postcards
        work.contributing_institution = ['Andover Newton Theological School Franklin Trask Library']
        work.format_digital = ['JPEG']
        work.types = ['Still Image']
        work.format_original = ['Postcards']
        work.save!
      rescue => e
        errors << [work, e]
      end
      progress.increment
    end
    if errors.present?
      $stderr.puts "-- ERRORS REPORTED"
      $stderr.puts "#{work.id} - #{e.message}\n#{e.backtrace[0..6]}"
    end
  end

  desc 'images-of-the-ancient-near-east fixes'
  task images: [:environment] do
    col = Collection.where(slug: 'images-of-the-ancient-near-east').first
    raise 'collection not found' unless col.present?

    progress = ProgressBar.create(format: "%t %c of %C %a %B %p%%", total: ActiveFedora::Base.where(member_of_collection_ids_ssim: col.id, has_model_ssim: ['Work']).count)
    errors = []
    ActiveFedora::Base.where(member_of_collection_ids_ssim: col.id, has_model_ssim: ['Work']).each do |work|
      begin
        # Remove trailing period from title and subject fields
        # Remove “Place” value
        # Add Format (Original): Slides (photographs)
        # Add Format (Digital): JPEG
        # Add Type: Still Image
        # Correct Contributing Institution field to be: Southwestern Baptist Theological Seminary Libraries
        work.titles = work.titles.map {|t| t.gsub(/\.$/, '') }
        work.place = nil
        work.format_original = ['Slides (photographs)']
        work.format_digital = ['JPEG']
        work.types = ['Still Image']
        work.contributing_institution = ['Southwestern Baptist Theological Seminary Libraries']
        work.save!
      rescue => e
        errors << [work, e]
      end
      progress.increment
    end
    if errors.present?
      $stderr.puts "-- ERRORS REPORTED"
      $stderr.puts "#{work.id} - #{e.message}\n#{e.backtrace[0..6]}"
    end
  end

  desc 'shape-note-tune-books fixes'
  task shape_note: [:environment] do
    col = Collection.where(slug: 'shape-note-tune-books').first
    raise 'collection not found' unless col.present?

    progress = ProgressBar.create(format: "%t %c of %C %a %B %p%%", total: ActiveFedora::Base.where(member_of_collection_ids_ssim: col.id, has_model_ssim: ['Work']).count)
    errors = []
    ActiveFedora::Base.where(member_of_collection_ids_ssim: col.id, has_model_ssim: ['Work']).each do |work|
      begin
        # Correct Contributing Institution field to be: Southwestern Baptist Theological Seminary Libraries
        # Add Format (Digital): JPEG
        # Add Type: Still Image AND Text
        # Format (Original): Tune books

        work.contributing_institution = ['Southwestern Baptist Theological Seminary Libraries']
        work.format_digital = ['JPEG']
        work.types = ['Still Image', 'Text']
        work.format_original = ['Tune books']
        work.save!
      rescue => e
        errors << [work, e]
      end
      progress.increment
    end
    if errors.present?
      $stderr.puts "-- ERRORS REPORTED"
      $stderr.puts "#{work.id} - #{e.message}\n#{e.backtrace[0..6]}"
    end
  end

  desc 'selected-photographs-of-ancient-near-eastern-and-mediterranean-sites fixes'
  task photographs_near_eastern: [:environment] do
    col = Collection.where(slug: 'selected-photographs-of-ancient-near-eastern-and-mediterranean-sites').first
    raise 'collection not found' unless col.present?

    progress = ProgressBar.create(format: "%t %c of %C %a %B %p%%", total: ActiveFedora::Base.where(member_of_collection_ids_ssim: col.id, has_model_ssim: ['Work']).count)
    errors = []
    ActiveFedora::Base.where(member_of_collection_ids_ssim: col.id, has_model_ssim: ['Work']).each do |work|
      begin
        # Remove Place
        work.place = nil
        work.save!
      rescue => e
        errors << [work, e]
      end
      progress.increment
    end
    if errors.present?
      $stderr.puts "-- ERRORS REPORTED"
      $stderr.puts "#{work.id} - #{e.message}\n#{e.backtrace[0..6]}"
    end
  end
end
