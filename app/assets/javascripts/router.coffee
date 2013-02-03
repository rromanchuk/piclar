models = {}
collections = {}
views = {}

Router = Backbone.Router.extend
  _historyLimit: 10
  history: []

  routes:
    '':                          'index'

  initialize: ->
    @on('all', @_manageHistory)

    app.log('[app.Router]: initialize')

  _manageHistory: (rule, params...) ->
    # if (rule.indexOf('route') > - 1)

    @history.unshift(window.location.href)

    if @history.length > @_historyLimit
      @history.length = @_historyLimit

  index: ->
    new app.modules.Parallax()

app.Router = Router
