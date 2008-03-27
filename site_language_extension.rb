# Uncomment this if you reference any of your controllers in activate
require_dependency 'application'

class SiteLanguageExtension < Radiant::Extension
  version "1.0"
  description "Habla Nederlands, sir? Si oder non?"
  url "http://openminds.be/"
  
  define_routes do |map|
    map.connect 'admin/site_language/:action', :controller => 'admin/site_languages'
    begin
      SiteLanguage.codes.each do |code|
        langname = Locale.new(code).language.code
        map.connect "#{langname}/*url", :controller => 'site', :action => 'show_page', :language => code
      end
    rescue
      # raise SiteLanguageError, "Migrations not ran yet.."
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
  
  def enhance_classes
    # Mixin'in the Mojo
    # It seems impossible to add a before_filter to Admin::AbstractModelController from here :/
    Admin::PageController.class_eval do
      before_filter :set_locale
      def set_locale
        Locale.set params[:language] || SiteLanguage.default
      end
    end
    Admin::SnippetController.class_eval do
      before_filter :set_locale
      def set_locale
        Locale.set params[:language] || SiteLanguage.default
      end
    end

    Admin::AbstractModelController.send :include, SiteLanguage::AbstractModelControllerExtensions
    SiteController.send :include, SiteLanguage::SiteControllerExtensions
    Page.send :include, SiteLanguage::PageExtensions
    
    Object.class_eval do
      include Globalize
      Locale.set_base_language(SiteLanguage.default)
    end

    PagePart.class_eval do
      translates :content
    end
    
    Snippet.class_eval do
      translates :content
    end
  end
end


class SiteLanguageError < StandardError
end