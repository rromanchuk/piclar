/*
 *
 * Based on WKSlider by Alex Gibson, http://miniapps.co.uk/
 * Released under MIT license
 * http://miniapps.co.uk/license/
 *
 */

var iSlider = function(el, options) {
    var transforms = 'webkitTransform MozTransform msTransform OTransform transform'.split(' '),
        isAndroid = navigator.userAgent.match(/(Android)\s+([\d.]+)/),
        i, l;

    this.options = options || {};

    this.element = typeof el === 'object' ? el : document.getElementById(el);

    // Detect support for Webkit CSS 3d transforms
    this.supportsWebkit3dTransform = ('WebKitCSSMatrix' in window && 'm11' in new WebKitCSSMatrix()) && !isAndroid;

    this.knobs = this.element.getElementsByClassName(this.options.knob || 'islider-knob');
    this.knobsWidth = this.knobs[0].offsetWidth; // all knobs should be the same size
    
    this.knobsNum = this.knobs.length;
    this.target = this.knobsNum - 1;
    this.multiKnob = this.knobsNum > 1;
    this.positions = [0];
    this.percents = [0];
    
    if (this.multiKnob) {
        for (i = 0, l = this.knobsNum; i < l; i++) {
            this.knobs[i].setAttribute('data-id', i);
            this.positions[i] = 0;
            this.percents[i] = 0;
        }
    }

    // Get track width
    this.track = this.element.getElementsByClassName(this.options.track || 'islider-track')[0];
    this.trackWidth = this.track.offsetWidth;
    this.trackOffset = this.track.offsetLeft;

    this.diff = this.trackWidth - this.knobsWidth;

    // TODO: add legacy browsers support
    this.transform = 'transform';
    
    for (i = 0, l = transforms.length; i < l; i++) {
        (transforms[i] in this.element.style) && (this.transform = transforms[i]);
    }

    if (typeof window.ontouchstart !== 'undefined') {
        this.element.addEventListener('touchmove', this, false);
        this.element.addEventListener('touchend', this, false);
    }
    else {
        this.element.addEventListener('mousedown', this, false);
    }
};

iSlider.prototype.touchmove = function(e) {
    if (this.options.onBeforeDragMove && !this.options.onBeforeDragMove.call(this, e)) {
        return;
    }

    this.moveKnobTo(e, e.targetTouches[0].pageX);
};
iSlider.prototype.touchmove = function(e) {
    if (this.options.onBeforeDragMove && !this.options.onBeforeDragMove.call(this, e)) {
        return;
    }

    this.moveKnobTo(e, e.targetTouches[0].pageX);
};
iSlider.prototype.touchend = function(e) {
    if (this.options.onBeforeDragEnd && !this.options.onBeforeDragEnd.call(this, e)) {
        return;
    }

    this.moveKnobTo(e, e.changedTouches[0].pageX);

    this.options.onDragEnd && !this.options.onDragEnd.call(this, e);
};

iSlider.prototype.mousedown = function(e) {
    if (this.options.onBeforeDragStart && !this.options.onBeforeDragStart.call(this, e)) {
        return;
    }

    this.moveKnobTo(e, e.pageX);

    this.element.addEventListener('mousemove', this, false);
    this.element.addEventListener('mouseup', this, false);
};
iSlider.prototype.mousemove = function(e) {
    if (this.options.onBeforeDragMove && !this.options.onBeforeDragMove.call(this, e)) {
        return;
    }

    this.moveKnobTo(e, e.pageX);
};
iSlider.prototype.mouseup = function(e) {
    if (this.options.onBeforeDragEnd && !this.options.onBeforeDragEnd.call(this, e)) {
        return;
    }

    this.moveKnobTo(e, e.pageX);

    this.element.removeEventListener('mousemove', this, false);
    this.element.removeEventListener('mouseup', this, false);

    this.options.onDragEnd && !this.options.onDragEnd.call(this, e);
};

// Moves the slider
iSlider.prototype.moveKnobTo = function(e, x) {
    e.preventDefault();
    
    var pos = Math.min(Math.max(0, (x - this.trackOffset - this.knobsWidth / 2) | 0), this.trackWidth - this.knobsWidth);
    
    if (this.multiKnob) {
        var id = e.target.getAttribute('data-id');
        
        if (id === null) {// tap on this.element
            this.target = this.findClosestKnob(pos);
        }
        else {// dragging knob
            this.target = +id;
        }
    }
    
    if (this.options.onBeforeChange && !this.options.onBeforeChange.call(this, pos, x, e)) {
        return;
    }

    this.setSliderPos(pos);
};
iSlider.prototype.setKnobPos = function() {
    // Use Webkit CSS 3d transforms for hardware acceleration if available
    if (this.supportsWebkit3dTransform) {
        this.knobs[this.target].style.webkitTransform = 'translate3d(' + this.positions[this.target] + 'px, 0, 0)';
    }
    else {
        this.knobs[this.target].style[this.transform] = 'translateX(' + this.positions[this.target] + 'px)';
    }

    this.options.onChange && this.options.onChange.call(this, this.percents, this.target);
};

iSlider.prototype.setSliderPos = function(pos, target) {
    (typeof target !== 'undefined') && (this.target = target);

    this.percents[this.target] = pos / this.diff;
    this.positions[this.target] = pos;

    this.setKnobPos();
};
iSlider.prototype.setSliderPerc = function(perc, target) {
    (typeof target !== 'undefined') && (this.target = target);

    this.percents[this.target] = perc;
    this.positions[this.target] = perc * this.diff;

    this.setKnobPos();
};

iSlider.prototype.findClosestKnob = function(x) {
    var i = 0,
        l = this.knobsNum,
        tmp = 0,
        diff = Infinity,
        res = 0;
    
    for (; i < l; i++) {
        tmp = Math.abs(this.positions[i] - x);

        if (diff > tmp) {
            diff = tmp;
            res = i;
        }
    }
    
    return res;
};

// Event handler
iSlider.prototype.handleEvent = function(e) {
    if (typeof(this[e.type]) === 'function') {
        return this[e.type](e);
    }
};
