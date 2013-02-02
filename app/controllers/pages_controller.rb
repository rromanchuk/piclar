class PagesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json, :xml, :html
  
  def sandbox

  end

  def coming_soon

  end

end