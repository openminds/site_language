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
end