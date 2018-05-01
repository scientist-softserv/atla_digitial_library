# require 'oai'
# require 'libxml'
#
# class Playground
#   def initialize(opts = {})
#     @url = opts[:url]
#     @image_url = opts[:image_url]
#     @headers = opts[:headers]
#
#     @client = OAI::Client.new(@url, headers: @headers, parser: 'libxml', metadata_prefix: 'mods')
#   end
#
#   def identifiers
#     @identifiers_response ||= @client.list_identifiers
#   end
#
#   def list_records
#     @list_records_response ||= @client.list_records
#   end
#
#   def get_record(opts = {})
#     @client.get_record(opts)
#   end
# end
#
# client = Playground.new({
#   url: 'http://commons.ptsem.edu/api/oai-pmh',
#   image_url: 'http://commons.ptsem.edu/',
#   default_collection_name: 'Princeton Theological Commons Collection',
#   test: false,
#   name: 'ptsem',
#   headers: { from: 'rob@notch8.com' }
# })
#
# puts "Fetching Identifiers..."
#
# total = client.identifiers.doc.find('.//resumptionToken').to_a.first.attributes['completeListSize'].to_i
# remaining = total
#
# client.identifiers.full.each do |identifier|
#   # print "."
#   # $stdout.flush
#
#   remaining -= 1
#
#   if remaining % 100 == 0
#     puts "Remaining: #{remaining}"
#     puts "Fetching #{identifier.identifier}..."
#
#     record = client.get_record({identifier: identifier.identifier})
#
#     puts "Record:"
#     metadata = record.record.metadata&.child&.children&.each_with_object({}) do |node, hash|
#       case node.name
#       when 'title'
#         hash['title'] ||= []
#
#         node.content.split(/[:|]/).each do |c| # split by ':' and '|'
#           hash['title'] << c.strip
#         end
#       end
#     end
#
#     metadata
#   end
#   # puts rec.identifier
#   # puts rec.status
#   # puts rec.datestamp
#   # puts rec.set_spec
# end
#
# puts "Total Identifiers: #{client.identifiers.count}"
#
# total = 0
#
# client.list_records.each do |rec|
#   total += 1
# end
#
# puts "Total Records: #{total}"
