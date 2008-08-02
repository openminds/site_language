module SiteLanguageTags
  include Radiant::Taggable

  tag 'sitelanguages' do |tag|
    tag.expand
  end

  tag 'sitelanguages:each' do |tag|
    result = []
	  SiteLanguage.codes.each do |lang|
      tag.locals.language = lang
      result << tag.expand
    end
    result
  end

  tag 'sitelanguages:each:sitelanguage' do |tag|
    lang = tag.locals.language.to_s
    nice_lang = Locale.new(lang).language.to_s
    lang == Locale.active.code ? nice_lang : %{<a href="/#{nice_lang.downcase}/">#{nice_lang}</a>} 
  end
  
  tag 'sitelanguages:nav' do |tag|
    o = %{<ul id="nav_lang">\n}
    langs = SiteLanguage.find(:all)
    langs.each do |lang|
      next unless lang.show_in_langnav
      nice_lang = Locale.new(lang.code).language.code
      classes = ""
      classes << "current " if lang.code == Locale.active.code
      classes << "first" if lang == langs.first
      classes.strip!
      css_class = classes.blank? ? '' : " class=\"#{classes}\"" 
      # If this language has a domain set, and it is not the current language, prepend the link with it's domain
      # If it does not have it's own domain, and we're no longer on the 'base' domain, it should go back to avoid duplicate content on different domains
      # if the current language doesn't have a domain, it defaults to the first SiteLanguage's domain, or none
      if lang.domain.blank?
        domain = langs.first.domain.blank? ? '': "http://#{langs.first.domain}"
      else
        domain = "http://#{lang.domain}"
      end
      link = (lang.code == Locale.active.code) ? nice_lang : "<a href=\"#{domain}#{tag.locals.page.translated_url(lang.code)}\">#{nice_lang}</a>"
      o += "\t<li#{css_class}>#{link}</li>\n"
    end
    codes = SiteLanguage.codes
    o += "</ul>\n"
  end
  
  tag 'translated_slug' do |tag|
    tag.locals.page.translated_slug(tag.attr['lang']||'nl-BE')
  end
  
  tag 'langcode' do |tag|
    (Locale.active || Locale.base_language).language.code
  end
  
  # Hacked standard_tags
  
  desc %{ 
    Renders a link to the page. When used as a single tag it uses the page's title
    for the link name. When used as a double tag the part in between both tags will
    be used as the link text. The link tag passes all attributes over to the HTML
    @a@ tag. This is very useful for passing attributes like the @class@ attribute
    or @id@ attribute. If the @anchor@ attribute is passed to the tag it will
    append a pound sign (<code>#</code>) followed by the value of the attribute to
    the @href@ attribute of the HTML @a@ tag--effectively making an HTML anchor.
    
    *Usage:*
    <pre><code><r:link [anchor="name"] [other attributes...] /></code></pre>
    or
    <pre><code><r:link [anchor="name"] [other attributes...]>link text here</r:link></code></pre>
  }
  tag 'link' do |tag|
    options = tag.attr.dup
    anchor = options['anchor'] ? "##{options.delete('anchor')}" : ''
    attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
    attributes = " #{attributes}" unless attributes.empty?
    text = tag.double? ? tag.expand : tag.render('title')
    if defined?(SiteLanguage) && SiteLanguage.count > 0
      %{<a href="/#{(Locale.active || Locale.base_language).language.code}#{tag.render('url')}#{anchor}"#{attributes}>#{text}</a>}
    else
      %{<a href="#{tag.render('url')}#{anchor}"#{attributes}>#{text}</a>}
    end
  end
  
  desc %{
    Renders a trail of breadcrumbs to the current page. The separator attribute
    specifies the HTML fragment that is inserted between each of the breadcrumbs. By
    default it is set to @>@.
    
    *Usage:* 
    <pre><code><r:breadcrumbs [separator="separator_string"] /></code></pre>
  }
  tag 'breadcrumbs' do |tag|
    page = tag.locals.page
    breadcrumbs = [page.breadcrumb]
    page.ancestors.each do |ancestor|
      if defined?(SiteLanguage) && SiteLanguage.count > 0
        breadcrumbs.unshift %{<a href="/#{(Locale.active || Locale.base_language).language.code}#{ancestor.url}">#{ancestor.breadcrumb}</a>}
      else
        breadcrumbs.unshift %{<a href="#{ancestor.url}">#{ancestor.breadcrumb}</a>}
      end
    end
    separator = tag.attr['separator'] || ' &gt; '
    breadcrumbs.join(separator)
  end
  
end