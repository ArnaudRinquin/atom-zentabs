{$, WorkspaceView, View}  = require 'atom'
ZentabsController = require '../lib/zentabs-controller'

describe "Zentabs", ->
  [item1, item2, item3, item4, pane] = []

  class TestView extends View
    @deserialize: ({title, longTitle}) -> new TestView(title, longTitle)
    @content: (title) -> @div title
    initialize: (@title, @longTitle) ->
    getTitle: -> @title
    getLongTitle: -> @longTitle
    serialize: -> { deserializer: 'TestView', @title, @longTitle }

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.deserializers.add(TestView)
    item1 = new TestView('Item 1')
    item2 = new TestView('Item 2')
    pane = atom.workspaceView.getActivePane()
    pane.addItem(item1, 0)
    pane.addItem(item2, 2)
    pane.showItem(item2)

    waitsForPromise ->
      atom.packages.activatePackage("zentabs")

  afterEach ->
    atom.deserializers.remove(TestView)

  describe "When a maximum tab limit is set", ->
    beforeEach ()->
      atom.config.set 'zentabs.maximumOpenedTabs', 4

      item3 = new TestView('Item 3')
      item4 = new TestView('Item 4')

      pane.addItem(item3, 0)
      pane.addItem(item4, 0)

    afterEach ()->
      atom.config.set 'zentabs.maximumOpenedTabs', null

    it "limits the number of opened tabs", ->
      expect(pane.getItems().length).toEqual 4
      item5 = new TestView('Item 5')
      pane.addItem(item5, 0)
      expect(pane.getItems().length).toEqual 4
    it "it removed the oldest active tab", ->

      pane.showItem item2 # -> should be removed
      pane.showItem item1
      pane.showItem item3
      pane.showItem item4

      item5 = new TestView('Item 5')
      pane.addItem(item5, 0)
      expect(pane.getItems().indexOf(item2)).toEqual -1

  describe "When manual mode is enabled", ->
    beforeEach ()->
      atom.config.set 'zentabs.manualMode', true
      atom.config.set 'zentabs.maximumOpenedTabs', 4

      item3 = new TestView('Item 3')
      item4 = new TestView('Item 4')

      pane.addItem(item3, 0)
      pane.addItem(item4, 0)

    afterEach ()->
      atom.config.set 'zentabs.manualMode', false
      atom.config.set 'zentabs.maximumOpenedTabs', null

    it "does not limits the number of opened tabs", ->
      expect(pane.getItems().length).toEqual 4
      item5 = new TestView('Item 5')
      pane.addItem(item5, 0)
      expect(pane.getItems().length).toEqual 5

  describe "When zentabs:cleanup is fired", ->
    beforeEach ()->
      atom.config.set 'zentabs.manualMode', true
      atom.config.set 'zentabs.maximumOpenedTabs', 4
      item3 = new TestView('Item 3')
      item4 = new TestView('Item 4')
      item5 = new TestView('Item 5')

      pane.addItem(item3, 0)
      pane.addItem(item4, 0)
      pane.addItem(item5, 0)

    afterEach ()->
      atom.config.set 'zentabs.manualMode', false
      atom.config.set 'zentabs.maximumOpenedTabs', null

    it "trigger a cleanup", ->
      expect(pane.getItems().length).toEqual 5
      atom.workspaceView.trigger 'zentabs:cleanup'
      expect(pane.getItems().length).toEqual 4
