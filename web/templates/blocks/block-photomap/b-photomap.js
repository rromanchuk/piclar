(function($){
S.blockPhotoMap = function(settings) {
    this.options = $.extend({
        center: {
            lat: 52.508712,
            lng: 13.375787
        },
        defaultZoom: 2
    }, settings);

    this.els = {};

    this.initialized = false;
};

S.blockPhotoMap.prototype.init = function() {
    if (this.initialized) return;

    this.els.block = $('.b-photomap');
    this.els.map = this.els.block.find('.b-p-canvas');

    this.initMap();

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

S.blockPhotoMap.prototype.logic = function() {
    // var that = this;

    // google.maps.event.addListener(this.map, 'click', handleMapClick);

    return this;
};

})(jQuery);
