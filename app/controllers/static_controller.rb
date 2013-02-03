class StaticController < ApplicationController
  respond_to :html
  
  def comingsoon
    render :layout => 'splash'
  end

end
