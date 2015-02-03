{CompositeDisposable} = require 'atom'
_ = require 'underscore-plus'
ZentabsController = require './zentabs-controller'

module.exports =

  config:
    maximumOpenedTabs:
      type: 'integer'
      default: 5
    manualMode:
      type: 'boolean'
      default: false
    showPinnedIcon:
      type: 'boolean'
      default: true
    neverCloseUnsaved:
      type: 'boolean'
      default: false

  activate: ->
    @paneSubscription = new CompositeDisposable
    for pane in atom.workspace.getPanes()
      zentabController = new ZentabsController(pane)
      @zentabsControllers ?= []
      @zentabsControllers.push(zentabController)
      @paneSubscription.add pane.onDidDestroy =>
        _.remove(@zentabsControllers, zentabController)
      zentabController

  deactivate: ->
    @paneSubscription.dispose()
    zentabController.remove() for zentabController in @zentabsControllers ? []
