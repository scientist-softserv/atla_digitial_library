desc 'Fixes mp3 facet duplications and properly set to MPEG'
task repair_format_digital: [:environment] do
  Work.find_each do |w|
    first = w.format_digital&.first
    if first && first&.downcase&.match?('mp3')
      w.format_digital = ['MPEG']
      w.save!
    end
  end
end
