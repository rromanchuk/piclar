// @require 'blocks/block-locationpicker/b-locationpicker.places.jst'

(function($){
S.blockLocationPicker = function(settings) {
    this.options = $.extend({
        center: {
            lat: 52.508712,
            lng: 13.375787
        },
        coords: null,
        defaultZoom: 2,
        markerZoom: 12,
        placesLimit: 20
    }, settings);

    this.els = {};

    this.initialized = false;
};

S.blockLocationPicker.prototype.init = function() {
    if (this.initialized) return;

    this.els.block = $('.b-locationpicker');
    this.els.map = this.els.block.find('.b-l-m-canvas');
    this.els.locations = this.els.block.find('.b-l-locations');
    this.els.locationsList = this.els.locations.find('.b-l-l-list');

    this.template = MEDIA.templates['blocks/block-locationpicker/b-locationpicker.places.jst'].render;
    this.markerImage = new google.maps.MarkerImage(S.env.marker);

    this.map = null;
    this.marker = null;

    this.places = null;
    this.selectedPlace = null;

    this.deferred = null;

    this.initMap();

    this.logic();

    this.options.coords && this.setMarker(new google.maps.LatLng(this.options.coords.lat, this.options.coords.lng));

    $.pub('b_locationpicker_init');

    this.initialized = true;

    return this;
};

S.blockLocationPicker.prototype.initMap = function() {
    var center = this.options.coords || this.options.center,
        gMapOptions = {
            zoom: this.options.defaultZoom,
            center: new google.maps.LatLng(center.lat, center.lng),
            mapTypeId: google.maps.MapTypeId.ROADMAP
        };

    this.map = new google.maps.Map(this.els.map[0], gMapOptions);

    return this;
};

S.blockLocationPicker.prototype.setMarker = function(location) {
    if (this.marker) {
        this.marker.setPosition(location);
    }
    else {
        this.marker = new google.maps.Marker({
            position: location,
            map: this.map,
            icon: this.markerImage
        });
        
        if (this.options.coords) {
            this.map.panTo(location);
            this.map.setZoom(this.options.markerZoom);
        }
    }
    
    $.pub('b_locationpicker_marked', { lat: location.lat(), lng: location.lng() });
};

S.blockLocationPicker.prototype.getPlaceById = function(id) {
    var factor = function(item) {
            return item.id === id;
        },
        res = _.filter(this.places, factor);


    return res.length ? res[0] : null;
};

S.blockLocationPicker.prototype.fetchPlaces = function(location) {
    if (this.deferred && (this.deferred.readyState !== 4)) {
        this.deferred.abort();
    }

    var that = this;

    var successHandler = function(res) {
        that.els.locations.removeClass('loading');

        if (res.length === 0) {
            that.els.locations.addClass('empty');
        }
        else {
            that.els.locationsList.append(that.template({ places: res }));
        }

        that.places = res;
        $.pub('b_locationpicker_req_succeeded', res);
    };
    var errorHandler = function() {
        that.els.locations.removeClass('loading').addClass('error');
        $.pub('b_locationpicker_req_failed');
    };

    this.els.locationsList.html('');
    this.els.locations[0].className = 'b-l-locations';
    this.els.locations.addClass('loading');

    location.limit = this.options.placesLimit;

    this.deferred = $.ajax({
        url: S.urls.places,
        data: location,
        type: 'GET',
        success: successHandler,
        error: errorHandler
    });
};

S.blockLocationPicker.prototype.logic = function() {
    var that = this;

    var handleMapClick = function(e) {
        that.setMarker(e.latLng);
    };
    var handleLocationPicked = function(e, data) {
        that.fetchPlaces(data);
    };
    var handleSelectPlace = function() {
        that.els.locationsList.find('.b-l-place.active').removeClass('active');
        this.className += ' active';

        that.selectedPlace = that.getPlaceById(this.getAttribute('data-placeid'));

        $.pub('b_locationpicker_picked', that.selectedPlace);
    };

    google.maps.event.addListener(this.map, 'click', handleMapClick);
    $.sub('b_locationpicker_marked', handleLocationPicked);
    this.els.locationsList.on('click', '.b-l-place', handleSelectPlace);

    return this;
};

})(jQuery);
