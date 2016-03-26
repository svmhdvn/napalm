{CompositeDisposable} = require 'atom'
Acorn = require 'acorn'
Escodegen = require 'escodegen'

NapalmView = require './napalm-view'
Github = require './helpers/github'

module.exports = Napalm =
  napalmView: null
  modalPanel: null
  subscriptions: null

  tried: false

  activate: (state) ->
    console.log('napalm')
    @napalmView = new NapalmView(state.napalmViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @napalmView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'napalm:toggle': => @toggle()
    window.Acorn = Acorn
    window.Escodegen = Escodegen

    atom.config.observe 'napalm.github.password', =>
      if @tried and @modalPanel.isVisible()
        @tried = false
        @modalPanel.hide()
        @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @napalmView.destroy()

  serialize: ->
    napalmViewState: @napalmView.serialize()

  toggle: ->
    if atom.config.get 'napalm.github.password'
      if editor = atom.workspace.getActiveTextEditor()
        selection = editor.getSelectedText()
        ast = Acorn.parse selection
        if func = @findFunction(ast)
          console.log window.func = func
          text = Escodegen.generate(func.node)
          console.log("module.exports = " + text)
	else
      @tried = true
      @modalPanel.show()

    Github.updateFile('test', 'lol.js', 'console.log("YUHTLHHRUPWFP")')
    .then (body) ->
      console.log 'Github successfully processed with response: ', body
    .catch (error) ->
      console.log 'Github failed with error: ', error

  findFunction: (node) ->
    if node.type is 'FunctionDeclaration'
      name = node.id.name
      node.id.name = ''
      return name: name, node: node
    else if node.type is 'VariableDeclaration' and node.declarations.length == 1
      declaration = node.declarations[0]
      if declaration.type is 'VariableDeclarator' and declaration.init.type is 'FunctionExpression'
        return name: declaration.id.name, node: declaration.init
    else if node.type is 'Program'
      for n in node.body
        if result = @findFunction(n)
          return result

    return null
