
desc 'Fixes mp3 facet duplications and properly set to MPEG'
task :repair_format_digital => [:environment] do
  Work.find_each do |w|
    if w.format_digital&.first.downcase =~ /mp3/
      w.format_digital = ["MPEG"]
      w.save!
    end
  end
end
