# encoding: utf-8
require 'foursquare2'

class Place < ActiveRecord::Base
  has_many :photos
  attr_accessible :foursquare_id, :title, :latitude, :longitude, :address, :type_text, :type

  # TYPE_UNKNOW = 0
  #   TYPE_HOTEL = 1
  #   TYPE_RESTAURANT = 2
  #   TYPE_GREAT_OUTDOOR = 3
  #   TYPE_ENTERTAINMENT = 4
    
  def fsq_client
    Foursquare2::Client.new(:client_id => CONFIG[:fsq_key], :client_secret => CONFIG[:fsq_secret])
  end

  def type
    1
  end

  def type_text
    "Hotel"
  end

  def address
    self[:address] || ""
  end

  def self.search(lat, lng)
    @fsq ||= Foursquare2::Client.new(:client_id => CONFIG[:fsq_key], :client_secret => CONFIG[:fsq_secret])
    venues = @fsq.search_venues(:ll => "#{lat},#{lng}")
    places = []
    venues.groups.first.items.each do |fsq_place|
      place = Place.where(foursquare_id: fsq_place.id).first
      puts place.inspect
      if place.blank?
        places << Place.create!(foursquare_id: fsq_place.id, title: fsq_place.name, latitude: fsq_place.location.lat, longitude: fsq_place.location.lng, address: fsq_place.location.address )
      else
        # temporarily fix all the fucked up places from not being utf8
        place.update_attribute(:title, fsq_place.name)
        place.update_attribute(:address, fsq_place.location.address)

        places << place
      end
    end
    places
  end

end