request = require 'request'
sha1 = require 'sha1'

username = 'napalmtest'
password = 'yoloswag360'

checksumCache = {}

api = (url, method, body) ->
  new Promise (resolve, reject) ->
    request({
      method  : method || 'GET'
      url     : 'https://api.github.com' + url
      body    : body || {}
      json    : true
      headers :
        'Accept': 'application/vnd.github.v3+json'
        'User-Agent': username
      }, (error, response, body) ->
        resolve(body)
    ).auth(username, password)

module.exports = Github =
  # https://developer.github.com/v3/repos/#create
  createRepo: (name) ->
    api('/user/repos', 'POST', {
      name: name
    })

  # https://developer.github.com/v3/repos/contents/#create-a-file
  # https://developer.github.com/v3/repos/contents/#update-a-file
  updateFile: (repo, filePath, fileContents) ->
    content = new Buffer(fileContents).toString('base64')

    update = ->
      api("/repos/#{username}/#{repo}/contents/#{filePath}", 'PUT', {
        message: message
        sha: sha
        content: content
      }).then (body) ->
        checksumCache[repo] = body.sha

    if checksumCache[repo]
      sha = checksumCache[repo]
      message = 'first commit of this useless package lol'
      return update()
    else
      message = 'updated package'

      return api("/repos/#{username}/#{repo}/contents/#{filePath}")
        .then (body) ->
          sha = body.sha
          checksumCache[repo] = sha
        .then update
