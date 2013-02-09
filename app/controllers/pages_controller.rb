# encoding: utf-8
class PagesController < ApplicationController

  respond_to :json, :html
  
  def sandbox

  end

  def about

  end

  def tos

  end

  def index
    render :layout => "splash"
  end

  def error_404
    @not_found_path = params[:not_found]
    render :layout => "splash"
  end

  def error_500
    render :layout => "splash"
  end

end
