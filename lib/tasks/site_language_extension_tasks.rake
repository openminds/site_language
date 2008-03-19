namespace :radiant do
  namespace :extensions do
    namespace :site_language do
      
      desc "Runs the migration of the Site Language extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          SiteLanguageExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          SiteLanguageExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Site Language to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[SiteLanguageExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(SiteLanguageExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
