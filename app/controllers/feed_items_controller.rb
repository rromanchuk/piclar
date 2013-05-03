# encoding: utf-8
class FeedItemsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def show
    @feed_item = FeedItem.find(params[:id])
    respond_with @feed_item
  end
  
  def index
    if params[:created_at]
      @feed_items = current_user.feed.where('created_at < ?', params[:created_at]).take(50)
    else
      @feed_items = current_user.feed.take(50)
    end
    
    respond_with @feed_items
  end

  def create
    @feed_item = FeedItem.create!(params[:feed_item])
    @feed_item.user = current_user
    #@feed_item.place = Place.find(params[:place][:id])
    @feed_item.save!
    @feed_item.photo = params[:feed_item][:photo]
    @feed_item.save!

    @feed_item.reload
    logger.error @feed_item.inspect
    logger.error @feed_item.user.inspect
    @feed_item = FeedItem.find(@feed_item.id)
    if params[:share_foursquare]
      @feed_item.share_on_fsq!
    end
    
    render 'feed_items/show'
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