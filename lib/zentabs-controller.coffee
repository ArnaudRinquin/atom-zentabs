{CompositeDisposable} = require 'atom'
{$, View} = require 'atom-space-pen-views'
_ = require 'underscore-plus'

module.exports =
class ZentabsController extends View

  @content: ()->
    @span ''

  initialize: (@pane) ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace', 'zentabs:cleanup', => @closeOverflowingTabs()
    @subscriptions.add atom.commands.add 'atom-workspace', 'zentabs:pintab', @pinTab
    @subscriptions.add atom.commands.add 'atom-workspace', 'zentabs:unpintab', @unpinTab

    @items = []
    @pinnedItems = []
    @pushItem(item) for item in @pane.getItems()

    @subscriptions.add @pane.onDidDestroy (pane) =>
      @unsubscribe() if pane is @pane

    @subscriptions.add @pane.onDidAddItem ({item}) =>
      @pushItem item
      unless atom.config.get 'zentabs.manualMode'
        setTimeout (=> @closeOverflowingTabs(item)), 0
      true

    @subscriptions.add @pane.onDidRemoveItem ({item}) =>
      _.remove @pinnedItems, item
      _.remove @items, item
      true

    @subscriptions.add @pane.onDidChangeActiveItem =>
      @updateActiveTab()
      true

    @updateActiveTab()
    @closeOverflowingTabs() unless atom.config.get 'zentabs.manualMode'

  destroy: =>
    @subscriptions.dispose()

  pushItem: (item)->
    @items.push item unless @pinnedItems.indexOf(item) > -1

  updateActiveTab: ->
    item = @pane.getActiveItem()
    return unless item
    return if @pinnedItems.indexOf(item) > -1 # do nothing if item is pinned
    _.remove @items, item
    @items.push item

  getRepositories: -> atom.project.getRepositories()

  closeOverflowingTabs: (newItem)->
    maxTabs = atom.config.get 'zentabs.maximumOpenedTabs'
    neverCloseUnsaved = atom.config.get 'zentabs.neverCloseUnsaved'
    neverCloseDirty = atom.config.get 'zentabs.neverCloseDirty'
    neverCloseNew = atom.config.get 'zentabs.neverCloseNew'

    tmpItems = @items.slice 0
    tmpItems.forEach (olderItem) =>
      if @items.length > maxTabs
        # Check tab saved status
        preventBecauseUnsaved = olderItem.buffer?.isModified() && neverCloseUnsaved;
        preventBecauseDirty = false
        preventBecauseNew = false

        if itemPath = olderItem.buffer?.file?.path
          @getRepositories().forEach (repo) ->
            return unless repo
            preventBecauseDirty = preventBecauseDirty || repo.isPathModified(itemPath) && neverCloseDirty
            preventBecauseNew = preventBecauseNew || repo.isPathNew(itemPath) && neverCloseNew

        unless preventBecauseUnsaved || preventBecauseDirty || preventBecauseNew || newItem == olderItem
          @pane.destroyItem olderItem

  pinTab: () =>
    tab = $('.tab.right-clicked')
    return unless tab

    view = atom.views.getView tab
    item = view.item

    _.remove @items, item

    @pinnedItems.push item unless @pinnedItems.indexOf(item) > -1

    tab.addClass 'pinned'
    # tab.find('.title').addClass 'icon icon-lock' if atom.config.get 'zentabs.showPinnedIcon'

  unpinTab: (event) =>
    tab = $('.tab.right-clicked')
    return unless tab

    view = atom.views.getView tab
    item = view.item

    _.remove @pinnedItems, item

    @pushItem item

    tab.removeClass 'pinned'
    # tab.find('.title').removeClass 'icon icon-lock'

    @closeOverflowingTabs()
