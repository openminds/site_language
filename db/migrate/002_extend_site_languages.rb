class ExtendSiteLanguages < ActiveRecord::Migration
  def self.up
    add_column :site_languages, :domain, :string, :required => false
    add_column :site_languages, :show_in_langnav, :boolean, :default => true
  end
  
  def self.down  
    remove_column :site_languages, :domain
    remove_column :site_languages, :show_in_langnav
  end
end
