// @require 'js/richmarker.js'

(function($) {
S.blockFavoritesMap = function(settings) {
    this.options = $.extend({
        feed: undefined
    }, settings);

    this.els = {};
};

S.blockFavoritesMap.prototype.init = function() {
    if (!this.options.feed) {
        return S.log('[OTA.blockFavoritesMap.init]: Failed to init! Please provide instance of feed to work with.');
    }

    this.feed = this.options.feed;

    this.maxZIndex = 1000; // not likely to have 1000 items in a feed

    this.els.block = $('.b-favorites-map');
    this.els.map = this.els.block.find('.b-f-m-canvas');

    this.resetBounds();

    this.initMap();
    this.logic();
   
    $.pub('b_favorites_map_init');

    return this;
};

S.blockFavoritesMap.prototype.getMarkerIndex = function(id) {
    return _.indexOf(this.markersMap, +id);
};

S.blockFavoritesMap.prototype.getFeedIndex = function(id) {
    return this.feed.getIndex(id);
};

S.blockFavoritesMap.prototype.initMap = function() {
    var gMapOptions = {
            // zoom: 12,
            // center: new google.maps.LatLng(S.data.city.coords.lat, S.data.city.coords.lon),
            mapTypeId: google.maps.MapTypeId.ROADMAP,
            disableDefaultUI: true,
            draggable: false,
            disableDoubleClickZoom: true,
            scrollwheel: false
        };

    this.map = new google.maps.Map(this.els.map[0], gMapOptions);
    this.markers = [];
    this.markersMap = [];

    this.activeMarker = null;

    if (this.feed.rendered) {// already have items rendered
        this.addMarkers(0, this.feed.rendered);
    }

    return this;
};
S.blockFavoritesMap.prototype.resetMap = function() {
    this.bounds.goog = new google.maps.LatLngBounds(
            new google.maps.LatLng(this.bounds.nw.lat, this.bounds.nw.lng),
            new google.maps.LatLng(this.bounds.se.lat, this.bounds.se.lng)
            );

    this.map.fitBounds(this.bounds.goog);
    return this;
};
S.blockFavoritesMap.prototype._handleMarkerClick = function() {
    $.pub('b_favorites_map_marker_click', this.get('ostro_place_id'));
};
S.blockFavoritesMap.prototype._addMarkerByFeedIndex = function(i) {
    var marker = new RichMarker({
        position: new google.maps.LatLng(this.feed.coll[i].position.lat, this.feed.coll[i].position.lng),
        map: this.map,
        draggable: false,
        flat: true,
        anchor: RichMarkerPosition.BOTTOM,
        content: '<div class="b-f-m-marker">' + this.feed.coll[i].counter + '</div>'
    });

    marker.set('ostro_place_id', +this.feed.coll[i].id);

    this.markersMap.push(+this.feed.coll[i].id);
    this.markers.push(marker);

    this.bounds.nw.lat = Math.min(this.bounds.nw.lat, this.feed.coll[i].position.lat);
    this.bounds.nw.lng = Math.min(this.bounds.nw.lng, this.feed.coll[i].position.lng);

    this.bounds.se.lat = Math.max(this.bounds.se.lat, this.feed.coll[i].position.lat);
    this.bounds.se.lng = Math.max(this.bounds.se.lng, this.feed.coll[i].position.lng);

    google.maps.event.addListener(marker, 'click', this._handleMarkerClick);

    return this;
};

S.blockFavoritesMap.prototype.addMarkers = function(i, j) {
    for (; i < j; i++) {
        this._addMarkerByFeedIndex(i);
    }

    return this.resetMap();
};

S.blockFavoritesMap.prototype.addMarker = function(id) {
    this._addMarkerByFeedIndex(this.getFeedIndex(id));
    return this.resetMap();
};

S.blockFavoritesMap.prototype.removeMarker = function(id) {
    var i = this.getMarkerIndex(id);

    this.markers[i].setMap(null);

    this.markersMap.splice(i, 1);
    this.markers.splice(i, 1);
};

S.blockFavoritesMap.prototype.removeMarkers = function() {
    var i = 0,
        l = this.markers.length;

    for (; i < l; i++) {
        this.markers[i].setMap(null);
    }

    this.markers.length = 0;
    this.markersMap.length = 0;
    return this;
};

S.blockFavoritesMap.prototype.resetBounds = function() {
    delete this.bounds;

    this.bounds = {
        nw: {
            lat: +Infinity,
            lng: +Infinity
        },
        se: {
            lat: -Infinity,
            lng: -Infinity
        }
    };
};

S.blockFavoritesMap.prototype.reset = function() {
    this.removeMarkers();
    this.resetBounds();
};

S.blockFavoritesMap.prototype.setActive = function(id) {
    var i = this.getMarkerIndex(id),
        f = this.getFeedIndex(id);
    
    if (this.activeMarker !== null) {
        var j = this.getMarkerIndex(this.activeMarker),
            k = this.getFeedIndex(this.activeMarker);

        this.markers[j].setContent('<div class="b-f-m-marker">' + this.feed.coll[k].counter + '</div>');
    }

    this.markers[i].setContent('<div class="b-f-m-marker active">' + this.feed.coll[f].counter + '</div>');
    this.markers[i].setZIndex(++this.maxZIndex);
    this.activeMarker = id;

    return this.activeMarker;
};

S.blockFavoritesMap.prototype.logic = function() {
    var that = this;

    var handleRender = function(e, data) {
        that.addMarkers(data.from, data.to);
    };

    var handleSetActive = function(e, id) {
        that.setActive(id);
    };

    var handleFeedReset = function() {
        that.reset();
    };

    $.sub('b_favorites_render_end', handleRender);
    $.sub('b_favorites_active', handleSetActive);
    $.sub('b_favorites_reset', handleFeedReset);

    return this;
};

})(jQuery);
