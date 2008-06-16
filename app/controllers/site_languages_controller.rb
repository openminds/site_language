class SiteLanguagesController < ApplicationController
  make_resourceful do
    actions :all

    response_for :create do
      flash[:notice] = "The language has been created."
      redirect_to site_languages_path
    end
    
    response_for :destroy do
      flash[:notice] = "The language has been deleted."
      redirect_to site_languages_path
    end
    
    response_for :update do
      flash[:notice] = "The language has been updated."
      redirect_to site_languages_path
    end
    
  end
end
