{$, View} = require 'atom'
_ = require 'underscore-plus'

module.exports =
class ZentabsController extends View

  @content: ()->
    @div =>
      @h1 'ZenTabs'

  initialize: (@pane) ->

    console.log 'initializing pane', @pane

    @items = []
    @subscriptions = []
    @paneContainer = @pane.getContainer()
    @pushItem(item) for item in @pane.getItems()

    @subscribe @paneContainer, 'pane:removed', (pane) =>
      @unsubscribe() if pane is @pane

    @subscribe @pane, 'pane:item-added', (e, item, index) =>
      @pushItem item
      console.log 'new tab', @items
      true

    @subscribe @pane, 'pane:item-removed', (e, item) =>
      _.remove @items, item
      console.log 'remove tab', @items
      true

    @subscribe @pane, 'pane:active-item-changed', =>
      @updateActiveTab()
      true

    @updateActiveTab()

  pushItem: (item)->
    @items.push item
    @closeOverflowingTabs()

  updateActiveTab: ->
    return unless @pane.activeItem
    _.remove @items, @pane.activeItem
    @items.push @pane.activeItem
    console.log 'update active', @items

  closeOverflowingTabs: ()->
    maxTabs = atom.config.getInt 'zentabs.maximumOpenedTabs' ? Infinity
    while @items.length > maxTabs
      olderTab = @items.shift()
      @pane.destroyItem olderTab
