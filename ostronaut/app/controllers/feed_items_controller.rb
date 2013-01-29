class FeedItemsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json, :html, :xml

  def index
    @feed_items = current_user.feed
    respond_with @feed_items
  end

  def create
    current_user
  end


end