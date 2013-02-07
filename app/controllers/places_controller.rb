# encoding: utf-8
class PlacesController < ApplicationController
  before_filter :authenticate_user!, :except => [:search]
  respond_to :json, :xml, :html
  
  def search
    @places = Place.search(params[:lat], params[:lng])
    logger.error @places.inspect
    render :index
  end

  def show
    @user = Place.find(params[:id])
  end

end