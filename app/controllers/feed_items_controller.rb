# encoding: utf-8
class FeedItemsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json, :html, :xml

  def show
    @feed_item = FeedItem.find(params[:id])
    respond_with @feed_item
  end
  
  def index
    @feed_items = current_user.feed
    respond_with @feed_items
  end

  def create
    @feed_item = FeedItem.create!(params[:feed_item])
    @feed_item.user = current_user
    @feed_item.place = Place.find(params[:place][:id])
    @feed_item.save!
    @feed_item.photo = params[:feed_item][:photo]
    @feed_item.save!

    if params[:share_foursquare]
      @feed_item.share_on_fsq!
    end
    
    render :show
  end

  def destroy
    @feed_item = current_user.feed_items.find(params[:id])
    @feed_item.destroy
    render nothing: true, status: 200
  end

  def unlike
    @feed_item = FeedItem.find(params[:id])
    current_user.likes.where(feed_item_id: @feed_item).first.destroy
    render :show
  end

end