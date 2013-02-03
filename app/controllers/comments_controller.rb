class CommentsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json
  
  def create
    @feed_item = FeedItem.find(params[:feed_item_id])
    @comment = current_user.comments.create!(params[:comment].merge(feed_item: @feed_item))
    render :show
  end

  def index

  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
  end


end