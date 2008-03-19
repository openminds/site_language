require File.dirname(__FILE__) + '/../test_helper'

class SiteLanguageExtensionTest < Test::Unit::TestCase
  
  # Replace this with your real tests.
  def test_this_extension
    flunk
  end
  
  def test_initialization
    assert_equal File.join(File.expand_path(RAILS_ROOT), 'vendor', 'extensions', 'site_language'), SiteLanguageExtension.root
    assert_equal 'Site Language', SiteLanguageExtension.extension_name
  end
  
end
