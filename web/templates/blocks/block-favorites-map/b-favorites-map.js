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

    this.els.block = $('.b-favorites-map');
    this.els.map = $('.b-f-m-canvas');

    this.initMap();
    this.logic();
   
    $.pub('b_favorites_map_init');

    return this;
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
    this.markers = {};

    return this;
};
S.blockFavoritesMap.prototype.addMarkers = function(i, j) {
    var image = new google.maps.MarkerImage('http://ostronaut.com/static/img/map/marker.png');

    for (; i < j; i++) {
        this.markers[this.feed.coll[i].id] = new google.maps.Marker({
          position: new google.maps.LatLng(this.feed.coll[i].position.lat, this.feed.coll[i].position.lng),
          map: this.map,
          icon: image,
          title: (i + 1) + ''
      });
    }

    return this;
};

S.blockFavoritesMap.prototype.logic = function() {
    var that = this;

    var handleRender = function(e, data) {
        that.addMarkers(data.from, data.to);
    };

    $.sub('b_favorites_render', handleRender);

    return this;
};

})(jQuery);
