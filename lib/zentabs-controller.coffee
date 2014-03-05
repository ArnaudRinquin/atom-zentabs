{$, View} = require 'atom'
_ = require 'underscore-plus'

module.exports =
class ZentabsController extends View

  @content: ()->
    @div =>
      @h1 'ZenTabs'

  initialize: (@pane) ->
    @items = []
    @subscriptions = []
    @paneContainer = @pane.getContainer()
    @pushItem(item) for item in @pane.getItems()

    @subscribe @paneContainer, 'pane:removed', (pane) =>
      @unsubscribe() if pane is @pane

    @subscribe @pane, 'pane:item-added', (e, item, index) =>
      @pushItem item
      true

    @subscribe @pane, 'pane:item-removed', (e, item) =>
      _.remove @items, item
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

  closeOverflowingTabs: ()->
    maxTabs = atom.config.getInt 'zentabs.maximumOpenedTabs' ? Infinity
    while @items.length > maxTabs
      olderTab = @items.shift()
      @pane.destroyItem olderTab
