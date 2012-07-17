/* Author:
    Max Degterev @suprMax
*/

;(function($) {
    var FValidate = function(settings) {
        this.options = $.extend({
            form: 'form',
            template: MEDIA.templates['blocks/module-validate/m-validate-error.jst'].render,
            validations: {},
            report: false
        }, settings);

        this.els = {};
        this.errors = {};
        this.errorsNum = 0;

        this.init();
        this.logic();
    };

    FValidate.prototype.init = function() {
        this.tmpl = this.options.template || false;
        (typeof this.options.debug === 'function') && (this.debug = this.options.debug);
        this.validation.external = this.options.validations;

        this.els.form = $(this.options.form);
        this.els.inputs = this.els.form.find('input[data-validate], textarea[data-validate]');
        this.els.containers = this.els.form.find('.m-validate-container');

        this.load();
    };

    FValidate.prototype.load = function() {
        var that = this;

        var loadPattern = function(elem, index) {
            var pattern = elem.getAttribute('data-pattern') || elem.getAttribute('pattern');

            if (pattern) {
                that.validation.patterns[elem.name] = new RegExp('^' + pattern + '$');
            }
        };

        // Load patterns from HTML
        this.els.inputs.filter('[data-filter*="pattern"]').forEach(loadPattern);
    };

    FValidate.prototype.logic = function() {
        var that = this;

        var handleSubmit = function(e) {
            if (that.validateForm()) {
                that.els.form.trigger('valid', e);
                that.options.onFormValid && that.options.onFormValid.call(that, e);
            }
            else {
                e.preventDefault();
                that.els.form.trigger('invalid', e);
                that.options.onFormInvalid && that.options.onFormInvalid.call(that, e);
            }
            that.handleErrors();
        };

        var handleInputFocus = function() {
            $(this).removeClass('error');
        };

        var handleErrorClick = function(e) {
            var relation = this.getAttribute('data-for');

            if (relation && relation !== '__none__') {
                this.parentNode.removeChild(this);

                var input = that.els.inputs.filter('[name="' + relation + '"]');

                // to avoid bug when sometimes keyboard doesn't show up
                $.os.ios && that.els.inputs.blur();

                input.length && input[0].focus();
            }
        };

        this.els.form.attr('novalidate', 'novalidate');

        this.els.form.on('submit', handleSubmit);
        this.els.inputs.on('focus', handleInputFocus);
        this.els.containers.on('click', '.m-validate-error', handleErrorClick);
    };

    FValidate.prototype.handleErrors = function() {
        var field,
            error;

        if (this.errorsNum) {
            for (field in this.errors) {
                error = this.tmpl ? this.tmpl(this.errors[field]) : this.errors[field].error;
                this.els.containers.filter('[data-for="' + field + '"]').append(error);
            }

            this.els.form.addClass('has_errors');
        }
        else {
            this.els.containers.find('.m-validate-error').remove();
            this.els.form.removeClass('has_errors');
        }
    };

    FValidate.prototype.validateForm = function() {
        var i, l, m, n,
            input, el,
            filters,
            name,
            failed;

        this.errors = {};
        this.errorsNum = 0;

        for (i = 0, l = this.els.inputs.length; i < l; i++) {
            input = this.els.inputs[i];
            el = $(input);
            name = input.name;
            filters = el.data('filter') ? el.data('filter').split(' ') : [];
            failed = [];

            if (!el.attr('disabled')) {
                el.attr('required') && filters.push('required');

                for (m = 0, n = filters.length; m < n; m++) {
                    this.validation.rules[filters[m]].call(input, this) || (failed.push(name + ':' + filters[m]));
                }

                if (typeof this.validation.external[name] === 'function') {
                    this.validation.external[name].call(input, this) || (failed.push(name + ':external'));
                }
            }

            if (!failed.length) {
                el.removeClass('error');
                el.addClass('valid');
            }
            else {
                this.debug('[m_validate]: "' + input.value + '" failed validation: ' + failed.join(', '));
                el.addClass('error');
                el.removeClass('valid');

                this.errors[name] = { el: el, name: name, error: el.data('error'), errorpos: el.data('errorpos') || 'right' };
                this.options.report && this.options.report.call(input, failed);

                this.errorsNum++;
            }
        }

        return !this.errors.length;
    };

    FValidate.prototype.validation = {
        patterns: {},
        external: {},
        rules: {
            required: function() {
                if (this.type === 'radio' || this.type === 'checkbox') {
                    return this.checked;
                }
                else {
                    return !!this.value.trim().length;
                }
            },
            email: function() {
                return !!this.value.trim().length && /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/.test(this.value);
            },
            number: function() {
                var min = +this.getAttribute('min') || -Infinity,
                    max = +this.getAttribute('max') || +Infinity,
                    val = +this.value.trim();

                return !isNaN(val) && val >= min && val <= max;
            },
            pattern: function(that) {
                return that.validation.patterns[this.name].test(this.value);
            }
        }
    };

    FValidate.prototype.debug = function(msg) {
    };

    $.fn.mod_validate = function(settings) {
        var options = $.extend({
            validations: {}
        }, settings);
        
        var report = function(failed) {
            $.pub('m_validate_error', {
                name: this.name,
                value: this.value,
                message: this.getAttribute('data-error'),
                failed: failed
            });
        };

        this.forEach(function(elem, index) {
            var id = 'validate_' + (Math.random() * 99999 | 0);

            elem.setAttribute('data-moduleid', id);
            S.modules[id] = new FValidate({
                form: elem,
                debug: S.log,
                validations: options.validations,
                report: report
            });

            $.pub('m_validate_ready', id);
            return S.modules[id];
        });
    };
})(jQuery);
