#!/usr/bin/ruby
require 'nokogiri'
require 'open-uri'
require 'csv'

# This script will retrieve a list of sets from an OAI-PMH endpoint and print them to a CSV file
# USAGE: ruby fetch_sets.rb url_to_endpoint (without verbs)
# EXAMPLE: ruby fetch_sets.rb https://thecatholicnewsarchive.org/crra-oaiserver

def add_sets(doc)
	@index += 1
	puts "Reading sets batch #{@index} ... "
	doc.css('ListSets set').each do |set|
    @sets_list[set.css('setSpec').first.content] = set.css('setName').first.content
  end
	if doc.css('resumptionToken').length > 0
    doc = get_doc(doc.css('resumptionToken').first.content)
    add_sets(doc)
  end
end

def get_doc(resumptionToken = nil)
  full_uri = "#{@uri}?verb=ListSets"
  full_uri = "#{@uri}?verb=ListSets&resumptionToken=#{resumptionToken}" unless resumptionToken.nil?
  Nokogiri::XML(open(full_uri))
end

@index = 0
@sets_list = {}
if ARGV[0].nil? 
	puts 'Please supply the OAI-PMH endpoint URL (with no verbs)'
	exit
end
@uri = ARGV[0]

doc = get_doc
add_sets(doc)

# write the data to a CSV
# puts @sets_list
filename = "#{@uri.split('/').last}_sets.csv"
puts "Writing #{filename}"
CSV.open(filename, "wb",
		:write_headers=> true,
		:headers => ["setSpec","setName"]
	) do |csv|
		@sets_list.each_pair {|k,v| csv << [k,v] }
end