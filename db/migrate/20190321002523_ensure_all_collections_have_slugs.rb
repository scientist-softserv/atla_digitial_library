class EnsureAllCollectionsHaveSlugs < ActiveRecord::Migration[5.1]
  def up
    Collection.all.each do |c|
      if c.slug.blank?
        c.set_slug
        c.save
      end
    end
  end

  def down
  end
end
