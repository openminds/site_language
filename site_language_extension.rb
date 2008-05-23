require_dependency 'application'

include Globalize
Locale.set_base_language(SiteLanguage.default)

class SiteLanguageExtension < Radiant::Extension
  version "1.0"
  description "Habla Nederlands, sir? Si oder non?"
  url "http://openminds.be/"
  
  define_routes do |map|
    map.connect 'admin/site_language/:action', :controller => 'admin/site_languages'
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
    admin.tabs.add "Languages", "/admin/site_language", :after => "Layouts", :visibility => [:admin, :developer]
    # We need globalize
    unless ActiveRecord::Base.respond_to? :translates
      raise SiteLanguageError, "Globalize does not appear to be installed."
    end
    enhance_classes
    Page.send :include, SiteLanguageTags
  end
  
  def deactivate
    admin.tabs.remove "Languages"
  end
  
  private
  
  def enhance_classes
    # stuff is not automatically inherited by already loaded classes
    Admin::PageController.class_eval do
      before_filter :set_locale, :except => [:index]
      def set_locale
        Locale.set(params[:language] || SiteLanguage.default)
      end
      protected
      def continue_url(options)
        options[:redirect_to] || (params[:continue] ? translated_page_edit_url(:id => @page.id, :language => params[:language]) : page_index_url)
      end
    end
    
    Admin::SnippetController.class_eval do
      before_filter :set_locale, :except => [:index]
      def set_locale
        Locale.set(params[:language] || SiteLanguage.default)
      end
      protected
      def continue_url(options)
        options[:redirect_to] || (params[:continue] ? translated_snippet_edit_url(:id => @snippet.id, :language => params[:language]) : snippet_index_url)
      end
    end

    SiteController.send(:include, SiteLanguage::SiteControllerExtensions)
    Page.send :include, SiteLanguage::PageExtensions

    PagePart.class_eval do
      translates :content
    end
    
    Snippet.class_eval do
      translates :content
    end
  end
end