class LikesController < ApplicationController
  respond_to :json

  def create
    @feed_item = FeedItem.find(params[:feed_item_id])
    @like = current_user.likes.create!(feed_item: @feed_item)
    respond_with @feed_item
  end

  def destroy
    @feed_item = FeedItem.find(params[:feed_item_id])
    like_item = Like.find(params[:id])
    like_item.destroy
    respond_with @feed_item
  end

end