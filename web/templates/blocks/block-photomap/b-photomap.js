// @require 'js/richmarker.js'
// @require 'js/markerclusterer.js'

(function($){
S.blockPhotoMap = function(settings) {
    this.options = $.extend({
        center: {
            lat: 52.508712,
            lng: 13.375787
        },
        defaultZoom: 2,
        places: []
    }, settings);

    this.els = {};

    this.initialized = false;
};

S.blockPhotoMap.prototype.init = function() {
    if (this.initialized) return;

    this.els.block = $('.b-photomap');
    this.els.map = this.els.block.find('.b-p-canvas');

    this.map = null;
    this.markers = [];
    this.clusterer = null;

    this.markerAnchor = new google.maps.Point(25, 50);

    this.initMap();
    this.initMarkers();
    this.initClusterer();

    this.logic();

    $.pub('b_photomap_init');

    this.initialized = true;

    return this;
};

S.blockPhotoMap.prototype.initMap = function() {
    var gMapOptions = {
            zoom: this.options.defaultZoom,
            center: new google.maps.LatLng(this.options.center.lat, this.options.center.lng),
            mapTypeId: google.maps.MapTypeId.ROADMAP
        };

    this.map = new google.maps.Map(this.els.map[0], gMapOptions);

    return this;
};
S.blockPhotoMap.prototype.initMarkers = function() {
    var i = 0,
        l = this.options.places.length;

    for (; i < l; i++) {
        this.setMarker(this.options.places[i]);
    }

    return this;
};
S.blockPhotoMap.prototype.initClusterer = function() {
    var gClustererOptions = {
            zoomOnClick: true,
            averageCenter: true,
            maxZoom: 15
        };

    this.clusterer = new MarkerClusterer(this.map, this.markers, gClustererOptions);
    this.clusterer.fitMapToMarkers();

    return this;
};

S.blockPhotoMap.prototype.setMarker = function(data) {
    var marker = new RichMarker({
            position: new google.maps.LatLng(data.location[1], data.location[0]),
            map: this.map,
            draggable: false,
            flat: true,
            anchor: RichMarkerPosition.BOTTOM,
            content: '<div class="b-p-marker"><img src="' + data.thumb_url + '" alt="' + data.title + '"></div>'
        });

    marker.set('ostro_place_id', data.id);

    this.markers.push(marker);

    google.maps.event.addListener(marker, 'click', this._handleMarkerClick);
};
S.blockPhotoMap.prototype._handleMarkerClick = function() {
    $.pub('b_favorites_map_marker_click', this.get('ostro_place_id'));
    return this;
};
S.blockPhotoMap.prototype.logic = function() {
    var that = this;

    var handleMarkerClick = function(e, id) {
        console.log(id);
    };

    $.sub('b_favorites_map_marker_click', handleMarkerClick);

    return this;
};

})(jQuery);
