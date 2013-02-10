# encoding: utf-8

class FoursquareCategory < ActiveRecord::Base
  
  has_many :children, :class_name => "FoursquareCategory", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "FoursquareCategory"

  attr_accessible :name, :short_name, :foursquare_id, :icon

  def self.generate(categories=nil)
    categories = Place.fsq_client.venue_categories if categories.blank?
    categories.each do |category|
      new_category = FoursquareCategory.create!(name: category.name, short_name: category.shortName, foursquare_id: category.id, icon: category.icon)
      new_category.children << get_categories(category)
    end
  end

  def self.get_categories(categories)
   
  end

end