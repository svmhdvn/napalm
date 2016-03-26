{CompositeDisposable} = require 'atom'
{allowUnsafeEval} = require 'loophole'
Acorn = require 'acorn'
Escodegen = require 'escodegen'
exec = require('child_process').exec

NapalmView = require './napalm-view'
Github = require './helpers/github'

module.exports = Napalm =
  napalmView: null
  modalPanel: null
  subscriptions: null

  tried: false

  createNpmPackage: (func) ->
    username = atom.config.get 'napalm.github.username'
    repo = func.name
    repoUrl = "https://github.com/#{username}/#{repo}"
    sourceString = "module.exports = #{repo} = " + Escodegen.generate(func.node)
    packageName = "#{username}-#{repo}".toLowerCase()

    Github.createRepo(repo)
    .then ->
      Github.updateFile(repo, 'index.js', sourceString)
    .then ->
      new Promise (resolve, reject) ->
        exec "npm view #{packageName}", (error, stdout) ->
          if error
            resolve('1.0.0')
          else
            # LOL qualiT coding right 'ere
            allowUnsafeEval ->
              eval 'response = ' + stdout
              resolve(parseInt(response.version) + 1 + '.0.0')
    .then (version) ->
      packageJson = {
        name: "#{packageName}"
        main: 'index.js'
        version: "#{version}"
        description: repo
        keywords: [repo]
        repository: repoUrl
        license: 'MIT'
        author: username
      }

      return Github.updateFile(repo, 'package.json', JSON.stringify(packageJson)).then -> return version
    .then (version) ->
      new Promise (resolve, reject) ->
        exec "git clone #{repoUrl} ~/#{repo}", (error) ->
          if error then console.log error
          exec "npm publish ~/#{repo}", (error) ->
            if error then console.log error
            exec "rm -rf ~/#{repo}", (error) ->
              if error then console.log error
              projectRoot = atom.project.relativizePath(Napalm.editor.getDirectoryPath())[0]
              console.log 'project root: ', projectRoot
              exec "cd #{projectRoot} && npm install --save #{packageName}@#{version}", (error) ->
                resolve("Successfully polluted the Node ecosystem with '#{repo}' :)")

  activate: (state) ->
    @napalmView = new NapalmView(state.napalmViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @napalmView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'napalm:package': => @package()
    window.Acorn = Acorn
    window.Escodegen = Escodegen

    atom.config.observe 'napalm.github.password', =>
      if @tried and @modalPanel.isVisible()
        @tried = false
        @modalPanel.hide()
        @package()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @napalmView.destroy()

  serialize: ->
    napalmViewState: @napalmView.serialize()

  package: ->
    if atom.config.get 'napalm.github.password'
      @editor = atom.workspace.getActiveTextEditor()
      if @editor
        selection = @editor.getSelectedText()
        useSelection = true
        if selection.length is 0
          useSelection = false
          selection = @editor.getText()
        ast = Acorn.parse selection
        removed = 0
        for func in @findFunctions ast
          requireString = "var #{func.name} = require('#{atom.config.get 'napalm.github.username'}-#{func.name}')"
          if useSelection
            @editor.setTextInBufferRange @editor.getSelectedBufferRange(), requireString
          else
            file = @editor.getText()
            sub = file.substr func.parent.start - removed, func.parent.end - func.parent.start
            removed += sub.length - requireString.length
            file = file.replace sub, requireString
            @editor.setText file

          @createNpmPackage(func).then (message) ->
            atom.notifications.addSuccess message
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
