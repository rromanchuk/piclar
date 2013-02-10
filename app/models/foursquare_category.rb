# encoding: utf-8

class FoursquareCategory < ActiveRecord::Base
  
  has_many :children, :class_name => "FoursquareCategory", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "FoursquareCategory"

  attr_accessible :name, :short_name, :foursquare_id, :icon

  def self.generate
    categories = Place.fsq_client.venue_categories
   
  end

  def self.get_categories(categories)
   
  end

end