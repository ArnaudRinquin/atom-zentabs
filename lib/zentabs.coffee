_ = require 'underscore-plus'
ZentabsController = require './zentabs-controller'

module.exports =

  configDefaults:
    maximumOpenedTabs: 5
    manualMode: false

  activate: ->
    @paneSubscription = atom.workspaceView.eachPane (pane) =>
      zentabController = new ZentabsController(pane)
      @zentabsControllers ?= []
      @zentabsControllers.push(zentabController)
      onPaneRemoved = (event, removedPane) =>
        return unless pane is removedPane
        _.remove(@zentabsControllers, zentabController)
        atom.workspaceView.off('pane:removed', onPaneRemoved)
      atom.workspaceView.on('pane:removed', onPaneRemoved)
      zentabController

  deactivate: ->
    @paneSubscription?.off()
    zentabController.remove() for zentabController in @zentabsControllers ? []
