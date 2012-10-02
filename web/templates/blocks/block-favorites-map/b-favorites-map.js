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

S.blockFavoritesMap.prototype._addMarkerByFeedIndex = function(i) {
    this.markersMap.push(+this.feed.coll[i].id);
    this.markers.push(new MarkerWithLabel({
        position: new google.maps.LatLng(this.feed.coll[i].position.lat, this.feed.coll[i].position.lng),
        map: this.map,
        icon: this.markerImage,
        labelContent: (i + 1) + '',
        labelClass: 'b-f-m-marker',
        labelAnchor: this.markerAnchor
    }));

    return this;
};

S.blockFavoritesMap.prototype.addMarkers = function(i, j) {
    for (; i < j; i++) {
        this._addMarkerByFeedIndex(i);
    }

    return this;
};

S.blockFavoritesMap.prototype.addMarker = function(id) {
    return this._addMarkerByFeedIndex(this.getFeedIndex(id));
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
