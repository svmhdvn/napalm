NapalmView = require './napalm-view'
{CompositeDisposable} = require 'atom'
Acorn = require 'acorn'

module.exports = Napalm =
  napalmView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @napalmView = new NapalmView(state.napalmViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @napalmView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'napalm:toggle': => @toggle()
    window.Acorn = Acorn

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @napalmView.destroy()

  serialize: ->
    napalmViewState: @napalmView.serialize()

  toggle: ->
    if editor = atom.workspace.getActiveTextEditor()
      selection = editor.getSelectedText()
