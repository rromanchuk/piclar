# encoding: utf-8
require 'foursquare2'

class Place < ActiveRecord::Base
  has_many :photos
  belongs_to :foursquare_category

  attr_accessible :foursquare_id, :title, :latitude, :longitude, :address, :type_text, :type

  TYPE_UNKNOWN = 0
  TYPE_HOTEL = 1
  TYPE_RESTAURANT = 2
  TYPE_GREAT_OUTDOOR = 3
  TYPE_ENTERTAINMENT = 4

  TYPE_TEXT = ['Не определено', 'Отель', 'Ресторан', 'Достопремечательность', 'Развлечения' ]


  def fsq_client
    Place.fsq_client
  end

  def self.fsq_client
    @fsq ||= Foursquare2::Client.new(:client_id => CONFIG[:fsq_key], :client_secret => CONFIG[:fsq_secret])
  end

  def type
    if self[:internal_type_id].blank? 
      if self.foursquare_category.blank?
        puts "blank"
        0
      else
        puts "not blank"
        self.foursquare_category.root.internal_category_id
      end
    else
      self[:internal_type_id]
    end
  end

  def type_text
    TYPE_TEXT[type]
  end

  def address
    self[:address] || ""
  end

  def update_place
    self.phone = venue.contact.phone
    self.address = venue.location.address
    self.city_name = venue.location.city
    #self.country
    save
  end

  def self.update_or_create(venues)
    venues.each do |venue|
      place = Place.where(foursquare_id: venue.id).first
      if place.blank?
        puts "creating #{venue.name}"
        place = Place.create!(foursquare_id: venue.id, title: venue.name, latitude: venue.location.lat, longitude: venue.location.lng, address: venue.location.address )
        place.foursquare_category = FoursquareCategory.find_by_foursquare_id(venue.categories.first.id) unless venue.categories.blank?
        place.save
        place.internal_type_id = place.foursquare_category.root.internal_category_id
        place.save
      else
        #venue = fsq_client.venue(foursquare_id)
        #type_text = venue.categories.first.name
        place.foursquare_category = FoursquareCategory.find_by_foursquare_id(venue.categories.first.id) if place.foursquare_category.blank? && !venue.category.blank?
        place.internal_type_id = place.foursquare_category.root.internal_category_id if place.type.blank?
        place.save
      end
    end
    
  end
  #handle_asynchronously :update_or_create

  def self.add_missing_categories
    places = Place.where(:foursquare_category_id => nil)
    places.each do |place|
      place.update_place_category
      sleep 1
    end
  end

  def self.add_missing_types
    places = Place.where(:type => nil)
    places.each do |place|
      place.update_attribute(:type, place.foursquare_category.root.internal_category_id) if !place.foursquare_category.blank? && !place.foursquare_category.root.internal_category_id.blank?
    end
  end

  def update_place_category
    venue = fsq_client.venue(foursquare_id)
    puts venue.to_yaml
    return if venue.category.blank?
    self.foursquare_category = FoursquareCategory.find_by_foursquare_id(venue.categories.first.id)
    save
  end

  def self.search(lat, lng)
    venues = Place.fsq_client.search_venues(:ll => "#{lat},#{lng}")
    if Rails.env.development?
      Place.update_or_create(venues.groups.first.items)
    else
      Place.delay.update_or_create(venues.groups.first.items)
    end
    places = []
    foursquare_ids = venues.groups.first.items.map(&:id)
    places = Place.where(:foursquare_id => foursquare_ids)
    places
  end

end