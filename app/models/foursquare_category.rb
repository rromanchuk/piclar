# encoding: utf-8

class FoursquareCategory < ActiveRecord::Base
  has_many :children
  belongs_to :parent, :class_name => "FoursquareCategory", :foreign_key => "parent_id"


  def generate
    categories = Place.fsq_client.venue_categories
    categories.each do |category|
      FoursquareCategory.create!(name: category.name, short_name: category.shortName, foursquare_id: category.id, icon: category.icon)
    end
  end

  def get_categories(category)
    if category.categories.each do |c|
      new_category = FoursquareCategory.create!(name: c.name, short_name: c.shortName, foursquare_id: c.id, icon: c.icon)
      c.parent << get_categories(new_category)
    end
  end
end