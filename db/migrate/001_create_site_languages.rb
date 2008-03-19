class CreateSiteLanguages < ActiveRecord::Migration
  def self.up
    create_table :site_languages do |t|
      t.column :code, :string
    end
  end

  def self.down
    drop_table :site_languages
  end
end
