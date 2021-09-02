# OVERRIDE: Hyrax 2.6.0 - to add derived: true
class CreateJpgService
  def self.create_jpgs(files)
    results = files.clone
    files.each do |file|
      next if file["file"].nil?
      next unless File.extname(file["file"]) == ".pdf"
      file_name = File.basename(file["file"], ".pdf")
      directory = Rails.root.join("tmp", "jpgs", file_name)
      FileUtils.mkdir_p directory unless File.exist?(directory)
      pdf_path = file.file.path
      img_path = Rails.root.join('tmp', 'jpgs', file_name, "#{file_name}.jpg")
      cmd = "convert -limit area 0 -quality 100 -density 400 #{pdf_path} #{img_path} 2>&1"
      Rails.logger.info("CMD: #{cmd}")
      cmd_result = system(cmd)
      raise "Failed to parse PDF #{pdf_path}: #{cmd_result}" unless $CHILD_STATUS.success?
      Dir.glob("#{directory}/*.jpg") do |jpg|
        jpg_file = File.open(Rails.root.join(jpg))
        results << Hyrax::UploadedFile.create(file: jpg_file, user_id: file.user_id, derived: true)
      end
    end
    results
  end
end
