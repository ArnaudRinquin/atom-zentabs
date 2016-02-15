{CompositeDisposable} = require 'atom'
_ = require 'underscore-plus'
ZentabsController = require './zentabs-controller'

module.exports =
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
