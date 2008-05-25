module SiteLanguage::ControllerExtensions

  module PageControllerExtensions
    def self.included(base)
      base.class_eval do
        before_filter :set_locale, :except => [:index]
      end
    end
    
    def set_locale
      Locale.set(params[:language] || SiteLanguage.default)
    end
    
    protected
    
    def continue_url(options)
      options[:redirect_to] || (params[:continue] ? translated_page_edit_url(:id => @page.id, :language => params[:language]) : page_index_url)
    end
  end
  
  module SnippetControllerExtensions
    def self.included(base)
      base.class_eval do
        before_filter :set_locale, :except => [:index]
      end
    end
    
    def set_locale
      Locale.set(params[:language] || SiteLanguage.default)
    end
    
    protected
    
    def continue_url(options)
      options[:redirect_to] || (params[:continue] ? translated_snippet_edit_url(:id => @snippet.id, :language => params[:language]) : snippet_index_url)
    end
  end
  
  module SiteControllerExtensions
    def self.included(base)
      base.class_eval do
        before_filter :set_language
      end
    end

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
  
end