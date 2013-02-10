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
    Place.fsq_client
  end

  def self.fsq_client
    @fsq ||= Foursquare2::Client.new(:client_id => CONFIG[:fsq_key], :client_secret => CONFIG[:fsq_secret])
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

  def self.update_or_create(venues)
    venues.each do |venue|
      place = Place.where(foursquare_id: venue.id)

      if place.blank?
        puts "creating #{venue.name}"
        Place.create!(foursquare_id: venue.id, title: venue.name, latitude: venue.location.lat, longitude: venue.location.lng, address: venue.location.address )
      else
        #venue = fsq_client.venue(foursquare_id)
        #type_text = venue.categories.first.name
      end
    end
    
  end
  #handle_asynchronously :update_or_create

  def self.search(lat, lng)
    venues = Place.fsq_client.search_venues(:ll => "#{lat},#{lng}")
    Place.delay.update_or_create(venues)
    places = []
    foursquare_ids = venues.groups.first.items.map(&:id)
    places = Place.where(:foursquare_id, foursquare_ids)
    places
  end

end