# encoding: utf-8

class FoursquareCategory < ActiveRecord::Base
  
  has_many :children, :class_name => "FoursquareCategory", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "FoursquareCategory"

  attr_accessible :name, :short_name, :foursquare_id, :icon

  class << self
    def generate
      categories = Place.fsq_client.venue_categories
      categories.each { |c| create_with_categories_hash(c) }
    end

    def create_with_categories_hash data, parent_id = nil
      subcategories = data.delete(:categories) || []
      parent = create! do |c|
        c.foursquare_id = data[:id]
        c.name = data[:name]
        c.short_name = data[:shortName]
        c.plural_name = data[:pluralName]
        c.icon = data[:icon]
        c.parent_id = parent_id
      end

      subcategories.each do |sc|
        create_with_categories_hash sc, parent.id
      end
    end

    def self.get_categories(categories)
    end
  end
end
