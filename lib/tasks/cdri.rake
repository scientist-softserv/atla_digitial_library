# coding: utf-8
namespace :cdri do
  desc 'woodcuts-and-metal-engravings-from-16th-19th-century-publications fixes'
  task wood: [:environment] do
    col = Collection.where(slug: 'woodcuts-and-metal-engravings-from-16th-19th-century-publications').first
    raise 'collection not found' unless col.present?

    progress = ProgressBar.new(ActiveFedora::Base.where(member_of_collection_ids_ssim: col.id, has_model_ssim: ['Work']).count)
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
      progress.increment!
    end
    if errors.present?
      $stderr.puts "-- ERRORS REPORTED"
      $stderr.puts "#{work.id} - #{e.message}\n#{e.backtrace[0..6]}"
    end
  end

  desc 'postcards-of-unitarian-and-universalist-church-buildings fixes'
  task postcards: [:environment] do
    col = Collection.where(slug: 'postcards-of-unitarian-and-universalist-church-buildings').first
    raise 'collection not found' unless col.present?

    progress = ProgressBar.new(ActiveFedora::Base.where(member_of_collection_ids_ssim: col.id, has_model_ssim: ['Work']).count)
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
      progress.increment!
    end
    if errors.present?
      $stderr.puts "-- ERRORS REPORTED"
      $stderr.puts "#{work.id} - #{e.message}\n#{e.backtrace[0..6]}"
    end
  end

end
