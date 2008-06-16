class SiteLanguage < ActiveRecord::Base
  class << self
    def codes
      find(:all).collect { |sl| sl.code }
    end

    def default
      'nl-BE'
    end
  end
  
  def validate
    errors.add("code", "has invalid format. Valid examples are 'nl-BE' and 'en-US'") unless RFC_3066.valid?(code)
  end
end
