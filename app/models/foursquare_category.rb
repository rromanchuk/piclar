# encoding: utf-8

class FoursquareCategory < ActiveRecord::Base
  has_many :children
  belongs_to :parent, :class_name => "FoursquareCategory", :foreign_key => "parent_id"


  def generate
    categories = Place.fsq_client.venue_categories
    categories.each do |category|
      
    end
  end

end