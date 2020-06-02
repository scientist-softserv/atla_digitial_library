namespace :atla do
    desc 'recalculates the announcement text'
    task update_announcement_text: [:environment] do
        puts "fetching work count..."
        work_count = Work.count

        puts "fetching contributor count..."
        contributor_count = Work.contributing_institutions.count

        string = "Discover <strong>#{work_count}</strong> images, texts, videos and sounds from <strong>#{contributor_count}</strong> contributors"

        puts "\nCounts: \n\tWorks: #{work_count} \n\tContributors: #{contributor_count}\n\n"

        puts "updating content..."
        ContentBlock.announcement_text = string

        puts "done."
    end
end
