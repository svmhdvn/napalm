module.exports =
class NapalmView
  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('napalm')

    # Create message element
    message = document.createElement('div')
    message.textContent = "Settings"
    message.classList.add('message')
    @element.appendChild(message)

    @username = document.createElement('input')
    @username.type = 'text'
    @username.classList.add('native-key-bindings')
    @username.value = atom.config.get('napalm.github.username') or ''
    @username.placeholder = 'Github Username'
    @element.appendChild @username

    @password = document.createElement('input')
    @password.type = 'text'
    @password.classList.add('native-key-bindings')
    @password.value = atom.config.get('napalm.github.password') or ''
    @password.placeholder = 'Github Password'
    @element.appendChild @password

    save = document.createElement('button')
    save.textContent = 'Save'
    save.onclick = =>
      atom.config.set 'napalm.github.username', @username.value
      atom.config.set 'napalm.github.password', @password.value
    @element.appendChild save

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
