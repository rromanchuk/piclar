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



end
