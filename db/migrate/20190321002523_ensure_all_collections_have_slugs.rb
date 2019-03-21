class EnsureAllCollectionsHaveSlugs < ActiveRecord::Migration[5.1]
  def up
    Collection.all.each do |c|
      unless c.slug.present?
        c.set_slug
        c.save
      end
    end
  end
  def down
  end
end
