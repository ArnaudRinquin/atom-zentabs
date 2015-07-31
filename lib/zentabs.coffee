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
    neverCloseNew:
      type: 'boolean'
      default: false
    neverCloseDirty:
      type: 'boolean'
      default: false

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.workspace.observePanes (pane) =>
      zentabController = new ZentabsController(pane)
      @zentabsControllers ?= []
      @zentabsControllers.push(zentabController)
      @subscriptions.add pane.onDidDestroy =>
        _.remove(@zentabsControllers, zentabController)
      zentabController

  deactivate: ->
    @subscriptions.dispose()
    zentabController.remove() && zentabController.destroy() for zentabController in @zentabsControllers ? []
