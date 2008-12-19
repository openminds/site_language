require_dependency 'application'

include Globalize
Locale.set_base_language(SiteLanguage.default)

class SiteLanguageExtension < Radiant::Extension
  version "1.0"
  description "Habla Nederlands, sir? Si oder non?"
  url "http://openminds.be/"
  
  define_routes do |map|
    map.resources :site_languages, :path_prefix => "/admin"
    
    map.translated_page_edit 'admin/pages/edit/:id/:language', :controller => 'admin/page', :action => 'edit'
    map.translated_snippet_edit 'admin/snippets/edit/:id/:language', :controller => 'admin/snippet', :action => 'edit'
    begin
      SiteLanguage.codes.each do |code|
        langname = Locale.new(code).language.code
        map.connect "#{langname}/*url", :controller => 'site', :action => 'show_page', :language => code
      end
    rescue
      #raise SiteLanguageError, "Migrations not ran yet.."
    end
  end

  def activate
    admin.tabs.add "Languages", "/admin/site_languages", :after => "Layouts", :visibility => [:admin, :developer]
    # We need globalize
    unless ActiveRecord::Base.respond_to? :translates
      raise SiteLanguageError, "Globalize does not appear to be installed."
    end
    enhance_classes
  end
  
  def deactivate
    admin.tabs.remove "Languages"
  end
  
  private
  
  def enhance_classes
    Admin::PagesController.send :include, SiteLanguage::ControllerExtensions::PageControllerExtensions
    Admin::SnippetsController.send :include, SiteLanguage::ControllerExtensions::SnippetControllerExtensions
    SiteController.send :include, SiteLanguage::ControllerExtensions::SiteControllerExtensions
    
    Page.send :include, SiteLanguage::PageExtensions
    Page.send :include, SiteLanguageTags

    PagePart.class_eval do
      translates :content
    end
    
    Snippet.class_eval do
      translates :content
    end
  end
end