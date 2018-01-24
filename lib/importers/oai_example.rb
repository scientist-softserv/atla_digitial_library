require 'progress_bar'
require 'csv'
require 'libxml'
require 'oai'

#url = 'http://commons.ptsem.edu/api/oai-pmh'
#name = 'ptsem'

url = "http://digitalpitts.emory.edu/collections/oai-pmh-repository/request"
name = "pitts"

client = OAI::Client.new url, :headers => { "From" => "rob@notch8.com" }, :parser => 'libxml', metadata_prefix: 'mods'
response = client.list_records

attributes = {
  status: {count: 0, example: nil},
  identifier: {count: 0, example: nil},
  datestamp: {count: 0, example: nil},
}

total = 0.0
bar = ProgressBar.new(response.doc.find(".//resumptionToken").to_a.first.attributes["completeListSize"].to_i)
records = response.full.each do | record|
#records = response.each do | record|
  total += 1
  if record.header
    if record.header.status
      attributes[:status][:count] += 1
      attributes[:status][:example] = record.header.status
    end
    if record.header.identifier
      attributes[:identifier][:count] += 1
      attributes[:identifier][:example] = record.header.identifier
    end
    if record.header.datestamp
      attributes[:datestamp][:count] += 1
      attributes[:datestamp][:example] = record.header.datestamp
    end
    record.header.set_spec.each do |spec|
      spec_name, spec_value = spec.content.split(":")
      spec_name = "h:" + spec_name
      attributes[spec_name] ||= {count: 0, example: nil}
      attributes[spec_name][:count] += 1
      attributes[spec_name][:example] = spec_value
    end
  end

  if record.metadata
    record.metadata.children.first.children.each do |child|
      child_name = "dc:" + child.name
      attributes[child_name] ||= {count: 0, example: nil}
      attributes[child_name][:count] += 1
      attributes[child_name][:example] = child.content
    end
  end

  if record.about
    record.about.children.first.children.each do |child|
      child_name = "a:" + child.name
      attributes[child_name] ||= {count: 0, example: nil}
      attributes[child_name][:count] += 1
      attributes[child_name][:example] = child.content
    end
  end
  bar.increment!
end


CSV.open("#{name}.csv", 'wb') do |csv|
  csv << ['attribute', 'quantity', 'frequency', 'example']
  csv << ['total', total]
  attributes.each do |k, v|
    csv << [k, v[:count], (v[:count] / total), v[:example]]
  end
end
