BlahView = require './blah-view'
{CompositeDisposable} = require 'atom'

module.exports = Blah =
  blahView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @blahView = new BlahView(state.blahViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @blahView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'blah:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @blahView.destroy()

  serialize: ->
    blahViewState: @blahView.serialize()

  toggle: ->
    console.log 'Blah was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
