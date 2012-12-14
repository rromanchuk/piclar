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
        places: [],
        overlayPopup: '.b-photomap-popup',
        overlayCheckin: '.b-photomap-checkin',
        clusterClass: 'b-p-cluster'
    }, settings);

    this.els = {};

    this.initialized = false;
};

S.blockPhotoMap.prototype.init = function() {
    if (this.initialized) return;

    this.els.block = $('.b-photomap');
    this.els.map = this.els.block.find('.b-p-canvas');

    this.els.popup = $(this.options.overlayPopup);
    this.els.checkin = $(this.options.overlayCheckin);

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
            clusterClass: this.options.clusterClass,
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
S.blockPhotoMap.prototype.showCheckin = function(url, lat, lng) {
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
        that.showCheckinOverlay(resp, lat, lng);

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
S.blockPhotoMap.prototype.showCheckinOverlay = function(resp, lat, lng) {
    this.story && (delete this.story);

    this.els.checkin.html(this.storyTemplate(resp));

    this.story = new S.blockStoryFull({
        elem: this.els.checkin.find('.b-story-full'),
        data: resp,
        removable: true
    });

    S.overlay.active() && S.overlay.hide();

    S.overlay.show({
        block: this.options.overlayCheckin,
        hash: lat + ',' + lng + '/' + resp.id
    });

    this.story.init();
};
S.blockPhotoMap.prototype.showPopupOverlay = function(item) {
    this.els.popup.html(this.popupTemplate(item));

    S.overlay.active() && S.overlay.hide();

    S.overlay.show({
        block: this.options.overlayPopup,
        hash: item.lat + ',' + item.lng
    });
};
S.blockPhotoMap.prototype.getItemByCoords = function(lat, lng) {
    var factor = function(item) {
        return item.lat === lat && item.lng === lng;
    };

    return _.filter(this.options.places, factor)[0];
};
S.blockPhotoMap.prototype.getItemById = function(ref, id) {
    var factor = function(item) {
        return item.feed_item_id === id;
    };

    return _.filter(ref.checkins, factor)[0];
};
S.blockPhotoMap.prototype.logic = function() {
    var that = this;

    var handleMarkerClick = function(e, index) {
        var ref = that.options.places[index];

        if (ref.checkins.length > 1) {
            that.showPopupOverlay(ref);
        }
        else {
            that.showCheckin(ref.checkins[0].feed_item_api_url, ref.lat, ref.lng);
        }
    };

    var handlePhotoClick = function(e) {
        var el = $(this),
            parent = el.parents('.b-p-p-list');

        that.showCheckin(el.data('url'), +parent.data('lat'), +parent.data('lng'));
    };

    var handleOverlayPopShow = function(e, data) {
        var coords, ref;

        if (S.overlay.isPart(that.options.overlayPopup)) {
            coords = S.overlay.getPart(window.location.hash).replace(that.options.overlayPopup + '/', '').split(',');
            ref = that.getItemByCoords(+coords[0], +coords[1]);

            ref && that.showPopupOverlay(ref);
        }
        if (S.overlay.isPart(that.options.overlayCheckin)) {
            var parts = S.overlay.getPart(window.location.hash).replace(that.options.overlayCheckin + '/', '').split('/'),
                id = +parts[1];

            coords = parts[0].split(',');
            ref = that.getItemByCoords(+coords[0], +coords[1]);

            if (ref) {
                var item = that.getItemById(ref, id);
                item && that.showCheckin(item.feed_item_api_url, ref.lat, ref.lng);
            }
        }
    };

    $.sub('b_photomap_marker_click', handleMarkerClick);
    $.sub('l_overlay_popshow', handleOverlayPopShow);
    this.els.popup.on('click', '.b-p-p-item', handlePhotoClick);

    return this;
};

})(jQuery);
