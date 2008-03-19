class Admin::SiteLanguagesController < ApplicationController
  # Remove this line if your controller should only be accessible to users
  # that are logged in:
  # no_login_required

  scaffold :site_language
end
