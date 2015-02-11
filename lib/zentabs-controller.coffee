{CompositeDisposable} = require 'atom'
{$, View} = require 'atom-space-pen-views'
_ = require 'underscore-plus'

module.exports =
class ZentabsController extends View

  @content: ()->
    @span ''

  initialize: (@pane) ->

    atom.commands.add 'atom-workspace', 'zentabs:cleanup', => @closeOverflowingTabs()
    atom.commands.add 'atom-workspace', 'zentabs:pintab', @pinTab
    atom.commands.add 'atom-workspace', 'zentabs:unpintab', @unpinTab

    @items = []
    @pinnedItems = []
    @subscriptions = new CompositeDisposable
    @pushItem(item) for item in @pane.getItems()

    @subscriptions.add @pane.onDidDestroy (pane) =>
      @unsubscribe() if pane is @pane

    @subscriptions.add @pane.onDidAddItem ({item}) =>
      @pushItem item
      @closeOverflowingTabs() unless atom.config.get 'zentabs.manualMode'
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

    atom.workspace.addBottomPanel(item: this)

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

  closeOverflowingTabs: ()->
    maxTabs = atom.config.get 'zentabs.maximumOpenedTabs'
    neverCloseUnsaved = atom.config.get 'zentabs.neverCloseUnsaved'

    while @items.length > 0 and @items.length > maxTabs
      olderTab = @items.shift()

      # Check tab saved status
      modified = olderTab.buffer?.isModified();

      unless neverCloseUnsaved and modified
        @pane.destroyItem olderTab

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
