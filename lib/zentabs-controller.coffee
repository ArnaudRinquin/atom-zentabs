{$, View} = require 'atom'
_ = require 'underscore-plus'

module.exports =
class ZentabsController extends View

  @content: ()->
    @span ''

  initialize: (@pane) ->

    atom.workspaceView.command 'zentabs:cleanup', => @closeOverflowingTabs()
    atom.workspaceView.command 'zentabs:pintab', @pinTab
    atom.workspaceView.command 'zentabs:unpintab', @unpinTab

    @items = []
    @pinnedItems = []
    @subscriptions = []
    @paneContainer = @pane.getContainer()
    @pushItem(item) for item in @pane.getItems()

    @subscribe @paneContainer, 'pane:removed', (pane) =>
      @unsubscribe() if pane is @pane

    @subscribe @pane, 'pane:item-added', (e, item, index) =>
      @pushItem item
      @closeOverflowingTabs() unless atom.config.get 'zentabs.manualMode'
      true

    @subscribe @pane, 'pane:item-removed', (e, item) =>
      _.remove @pinnedItems, item
      _.remove @items, item
      true

    @subscribe @pane, 'pane:active-item-changed', =>
      @updateActiveTab()
      true

    @updateActiveTab()
    @closeOverflowingTabs() unless atom.config.get 'zentabs.manualMode'

    atom.workspaceView.append(this)

  pushItem: (item)->
    @items.push item unless @pinnedItems.indexOf(item) > -1

  updateActiveTab: ->
    item = @pane.activeItem
    return unless item
    return if @pinnedItems.indexOf(item) > -1 # do nothing if item is pinned
    _.remove @items, item
    @items.push item

  closeOverflowingTabs: ()->
    maxTabs = atom.config.getInt 'zentabs.maximumOpenedTabs' ? Infinity
    while @items.length > maxTabs
      olderTab = @items.shift()
      @pane.destroyItem olderTab

  pinTab: ()=>
    tab = $('.tab.right-clicked').view()
    return unless tab

    window.tab = tab

    item = tab.item

    _.remove @items, item

    @pinnedItems.push item unless @pinnedItems.indexOf(item) > -1

    tab.addClass 'pinned'
    tab.find('.title').addClass 'icon icon-lock' if atom.config.get 'zentabs.showPinnedIcon'

  unpinTab: ()=>
    tab = $('.tab.right-clicked').view()
    return unless tab

    item = tab.item

    _.remove @pinnedItems, item

    @pushItem item

    tab.removeClass 'pinned'
    tab.find('.title').removeClass 'icon icon-lock'

    @closeOverflowingTabs()
