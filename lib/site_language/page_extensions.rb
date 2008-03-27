module SiteLanguage::PageExtensions
  def self.included(base)
    base.class_eval {
      translates :title, :breadcrumb, :slug
    }
  end
  
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