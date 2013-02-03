# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
#
# WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
# GO AFTER THE REQUIRES BELOW.
#
#= require jquery
#= require ./libs/underscore
#= require ./libs/backbone

#= require_tree ./plugins/
#= require utils

#= require router
#= require_tree ./models/
#= require_tree ./collections/
#= require_tree ./views/
#= require_tree ./modules/

app = _.extend(@app, Backbone.Events)

app.dom.html.removeClass('no-js').addClass('js')
app.dom.html.addClass('opera')                                   if app.browser.isOpera
app.dom.html.addClass('firefox')                                 if app.browser.isFirefox
app.dom.html.addClass('ie ie' + app.browser.isIE)                if app.browser.isIE
app.dom.html.addClass('ios ios' + app.browser.isIOS)             if app.browser.isIOS
app.dom.html.addClass('android android' + app.browser.isAndroid) if app.browser.isAndroid

app.router = new app.Router()
Backbone.history.start(pushState: true);

@app = app


