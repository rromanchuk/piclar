(function($) {
S.blockFavoritesMap = function(settings) {
    this.options = $.extend({
        feed: undefined,
        zoom: 12
    }, settings);

    this.els = {};
};

S.blockFavoritesMap.prototype.init = function() {
    if (!this.options.feed) {
        return S.log('[OTA.blockFavoritesMap.init]: Failed to init! Please provide instance of feed to work with.');
    }

    this.feed = this.options.feed;
    this.zoom = this.options.zoom;

    this.markerImage = new google.maps.MarkerImage(S.env.marker);
    this.markerActiveImage = new google.maps.MarkerImage(S.env.marker_active);

    this.markerAnchor = new google.maps.Point(10, 30);
    this.markerActiveAnchor = new google.maps.Point(10, 40);

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

    this.els.block = $('.b-favorites-map');
    this.els.map = $('.b-f-m-canvas');

    this.initMap();
    this.logic();
   
    $.pub('b_favorites_map_init');

    return this;
};

S.blockFavoritesMap.prototype.getMarkerIndex = function(id) {
    return _.indexOf(this.markersMap, +id);
};

S.blockFavoritesMap.prototype.getFeedIndex = function(id) {
    return feed.getIndex(id);
};

S.blockFavoritesMap.prototype.initMap = function() {
    var gMapOptions = {
            zoom: this.zoom,
            center: new google.maps.LatLng(S.data.city.coords.lat, S.data.city.coords.lon),
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
S.blockFavoritesMap.prototype.resetBounds = function() {
    this.bounds.goog = new google.maps.LatLngBounds(
            new google.maps.LatLng(this.bounds.nw.lat, this.bounds.nw.lng),
            new google.maps.LatLng(this.bounds.se.lat, this.bounds.se.lng)
            );

    this.map.fitBounds(this.bounds.goog);
    return this;
};
S.blockFavoritesMap.prototype._handleMarkerClick = function() {
    $.pub('b_favorites_map_marker_click', this.__ostro_place_id__);
};
S.blockFavoritesMap.prototype._addMarkerByFeedIndex = function(i) {
    var marker = new MarkerWithLabel({
        position: new google.maps.LatLng(this.feed.coll[i].position.lat, this.feed.coll[i].position.lng),
        map: this.map,
        icon: this.markerImage,
        labelContent: (i + 1) + '',
        labelClass: 'b-f-m-marker',
        labelAnchor: this.markerAnchor
    });

    marker.__ostro_place_id__ = +this.feed.coll[i].id;

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

    return this.resetBounds();
};

S.blockFavoritesMap.prototype.addMarker = function(id) {
    this._addMarkerByFeedIndex(this.getFeedIndex(id));
    return this.resetBounds();
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
S.blockFavoritesMap.prototype.setActive = function(id) {
    var i = this.getMarkerIndex(id);
    
    if (this.activeMarker !== null) {
        var j = this.getMarkerIndex(this.activeMarker);
        this.markers[j].setOptions({
            icon: this.markerImage,
            labelAnchor: this.markerAnchor
        });
    }

    this.markers[i].setOptions({
        icon: this.markerActiveImage,
        labelAnchor: this.markerActiveAnchor
    });
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

    $.sub('b_favorites_render', handleRender);
    $.sub('b_favorites_active', handleSetActive);

    return this;
};

})(jQuery);
