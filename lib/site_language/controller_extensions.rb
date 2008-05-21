module SiteLanguage::ControllerExtensions
  def self.included(base)
    base.class_eval do
      before_filter :set_locale
    end
    
    include SiteLanguageMethods
  end
  
  module SiteLanguageMethods
    def set_locale
      Locale.set params[:language] || SiteLanguage.default
    end
  
    def continue_url(options)
      options[:redirect_to] || (params[:continue] ? model_edit_url(:id => model.id, :language => params[:language]) : model_index_url)
    end
  end
end