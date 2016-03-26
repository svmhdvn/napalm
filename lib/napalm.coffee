{CompositeDisposable} = require 'atom'
Acorn = require 'acorn'
Escodegen = require 'escodegen'
exec = require('child_process').exec

NapalmView = require './napalm-view'
Github = require './helpers/github'

createNpmPackage = (func) ->
  username = atom.config.get 'napalm.github.username'
  repo = func.name
  repoUrl = "https://github.com/#{username}/#{repo}"
  sourceString = 'module.exports = ' + Escodegen.generate(func.node)

  Github.createRepo(repo)
  .then ->
    Github.updateFile(repo, 'index.js', sourceString)
  .then ->
    packageJson = {
      name: repo
      main: 'index.js'
      version: '1.0.0'
      description: repo
      keywords: [repo]
      repository: repoUrl
      license: 'MIT'
      author: username
    }

    Github.updateFile(repo, 'package.json', JSON.stringify(packageJson))
  .then (body) ->
    new Promise (resolve, reject) ->
      exec "git clone #{repoUrl} ~/#{repo}", (error) ->
        exec "npm publish ~/#{repo}", (error) ->
          resolve("I'm done!")

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
        useSelection = true
        if selection.length is 0
          useSelection = false
          selection = editor.getText()
        ast = Acorn.parse selection
        removed = 0
        for func in @findFunctions ast
          requireString = "var #{func.name} = require('#{atom.config.get 'napalm.github.username'}-#{func.name}')"
          if useSelection
            editor.setTextInBufferRange editor.getSelectedBufferRange(), requireString
          else
            file = editor.getText()
            sub = file.substr func.parent.start - removed, func.parent.end - func.parent.start
            removed += sub.length - requireString.length
            file = file.replace sub, requireString
            editor.setText file

          createNpmPackage(func).then console.log
    else
      @tried = true
      @modalPanel.show()


  findFunctions: (node) ->
    if node.type is 'FunctionDeclaration'
      name = node.id.name
      node.id.name = ''
      return name: name, node: node, parent: node
    else if node.type is 'VariableDeclaration' and node.declarations.length == 1
      declaration = node.declarations[0]
      if declaration.type is 'VariableDeclarator' and declaration.init.type is 'FunctionExpression'
        return name: declaration.id.name, node: declaration.init, parent: node
    else if node.type is 'Program'
      results = []
      for n in node.body
        if result = @findFunctions(n)
          results.push result
      return results

    return null
