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
    admin.tabs.add "Site Language", "/admin/site_language", :after => "Layouts", :visibility => [:admin, :developer]
    # We need globalize
    unless ActiveRecord::Base.respond_to? :translates
      raise SiteLanguageError
    end
    enhance_classes
    Page.send :include, SiteLanguageTags
  end
  
  def deactivate
    admin.tabs.remove "Site Language"
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

    # pass language again when save_and_continue_editing is used
    Admin::AbstractModelController.class_eval do
      def continue_url(options)
        options[:redirect_to] || (params[:continue] ? model_edit_url(:id => model.id, :language => params[:language]) : model_index_url)
      end
    end
    
    SiteController.class_eval do
      before_filter :set_language
      
      def set_language
        (redirect_to :language => SiteLanguage.default, :url => (params[:url] unless params[:url] == '/')) unless Locale.set params[:language] 
      end
      
      def show_page
        response.headers.delete('Cache-Control')
        url = params[:url].to_s
        lang = params[:language].to_s
        if (request.get? || request.head?) and live? and (@cache.response_cached?(lang + '-' + url))
          @cache.update_response(lang + '-' + url, response, request)
          @performed_render = true
        else
          show_uncached_page(url, lang)
        end
      end
      
      private

      def show_uncached_page(url, lang)
        @page = find_page(url)
        unless @page.nil?
          process_page(@page)
          @cache.cache_response(lang + '-' + url, response) if request.get? and live? and @page.cache?
          @performed_render = true
        else
          render :template => 'site/not_found', :status => 404
        end
      rescue Page::MissingRootPageError
        redirect_to welcome_url
      end
      
    end

    Object.class_eval do
      include Globalize
      Locale.set_base_language(SiteLanguage.default)
    end

    Page.class_eval do
      translates :title, :breadcrumb, :slug
      
      def translated_url(langcode)
        cur_lang = (Locale.active || Locale.base_language).code
        if self.class_name.eql?("RailsPage") # (from the share_layouts extension)
          r = "/#{Locale.new(langcode).language.code}/#{self.url[3..-1]}"
        else
          Locale.set langcode
          self.reload
          r = "/#{Locale.active.language.code}#{url}"
          Locale.set cur_lang
          self.reload
        end
        r
      end
      
      def translated_slug(langcode)
        cur_lang = (Locale.active || Locale.base_language).code
        Locale.set langcode
        self.reload
        r = slug
        Locale.set cur_lang
        self.reload
        r
      end
      
      def self.find_by_base_url(url)
        cur_lang = (Locale.active || Locale.base_language).code
        Locale.set Locale.base_language.code
        r = Page.find_by_url(url)
        Locale.set cur_lang
        r.reload
        r
      end
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