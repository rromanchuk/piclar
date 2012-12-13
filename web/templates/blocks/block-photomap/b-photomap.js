// @require 'js/richmarker.js'
// @require 'js/markerclusterer.js'
// @require 'blocks/block-story-full/b-story-full.js'
// @require 'blocks/block-story-full/b-story-full-overlay.jst'
// @require 'blocks/block-photomap/b-photomap.marker.jst'
// @require 'blocks/block-photomap/b-photomap.popup.jst'

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

    this.els.popup = $('.b-photomap-popup');
    this.els.checkin = $('.b-photomap-checkin');

    this.map = null;
    this.markers = [];
    this.clusterer = null;

    this.deferred = null;
    this.story = null;

    this.markerTemplate = MEDIA.templates['blocks/block-photomap/b-photomap.marker.jst'].render;
    this.popupTemplate = MEDIA.templates['blocks/block-photomap/b-photomap.popup.jst'].render;
    this.storyTemplate = MEDIA.templates['blocks/block-story-full/b-story-full-overlay.jst'].render;

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
        this.setMarker(this.options.places[i], i);
    }

    return this;
};
S.blockPhotoMap.prototype.initClusterer = function() {
    var gClustererOptions = {
            zoomOnClick: true,
            averageCenter: true,
            maxZoom: 15,
            clusterClass: 'b-p-cluster',
            richMarker: true
        };

    this.clusterer = new MarkerClusterer(this.map, this.markers, gClustererOptions);
    this.clusterer.fitMapToMarkers();

    return this;
};

S.blockPhotoMap.prototype.setMarker = function(data, index) {
    var marker = new RichMarker({
            position: new google.maps.LatLng(data.lat, data.lng),
            map: this.map,
            draggable: false,
            flat: true,
            anchor: RichMarkerPosition.BOTTOM,
            content: this.markerTemplate(data)
        }),
        length = data.checkins.length;

    this.markers.push(marker);

    marker.set('ostro_place_index', index);
    google.maps.event.addListener(marker, 'click', this._handleMarkerClick);
};
S.blockPhotoMap.prototype._handleMarkerClick = function() {
    $.pub('b_photomap_marker_click', this.get('ostro_place_index'));
    return this;
};
S.blockPhotoMap.prototype.showCheckin = function(url) {
    if (this.deferred && (this.deferred.readyState !== 4)) {
        // never supposed to see this
        this.deferred.abort();
    }
    var that = this;
        
    $.pub('b_photomap_checkin_loading');

    var handleAjaxError = function() {
        S.notifications.presets['server_failed']();

        $.pub('b_photomap_checkin_loaded', false);
    };

    var handleResponse = function(resp) {
        that.els.checkin.html(that.storyTemplate(resp));

        that.overlayStory = new S.blockStoryFull({
            elem: that.els.checkin.find('.b-story-full').addClass('overlay'),
            data: resp,
            removable: true
        });

        S.overlay.show({
            block: '.b-photomap-checkin',
            hash: resp.id
        });

        that.overlayStory.init();

        $.pub('b_photomap_checkin_loaded', true);
    };

    this.deferred = $.ajax({
        url: url,
        type: 'GET',
        dataType: 'json',
        success: handleResponse,
        error: handleAjaxError
    });

    return this;
};
S.blockPhotoMap.prototype.logic = function() {
    var that = this;

    var handleMarkerClick = function(e, index) {
        var ref = that.options.places[index];

        if (ref.checkins.length > 1) {
            that.els.popup.html(that.popupTemplate(ref));
            S.overlay.show({
                block: '.b-photomap-popup',
                hash: ref.lat + ',' + ref.lon
            });
        }
        else {
            that.showCheckin(ref.checkins[0].feed_item_api_url);
        }
    };

    var handlePhotoClick = function(e) {
        that.showCheckin(this.getAttribute('data-url'));
    };

    $.sub('b_photomap_marker_click', handleMarkerClick);
    this.els.popup.on('click', '.b-p-p-item', handlePhotoClick);

    return this;
};

})(jQuery);
