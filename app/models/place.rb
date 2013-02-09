# encoding: utf-8
require 'foursquare2'

class Place < ActiveRecord::Base
  has_many :photos
  attr_accessible :foursquare_id, :title, :latitude, :longitude, :address, :type_text, :type

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
        place.update_attribute(:title, fsq_place.name)
        places << place
      end
    end
    places
  end

end