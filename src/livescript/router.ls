/* Hic etiam homines magna cornua habentes 
 * longitudine quatuor pedum, et sunt etiam 
 * serpentes tante magnitudinis, ut unum bovem comedant integrum
 */

# Chromium's MessageSender wrapper for the god sake
# popup <-> background <-> content script
# TODO: write documentation

{ map, first, last, filter, each } = require 'prelude-ls'

export class Port
  (@name, @port) ->
    @listening-to-receive = []
    @listening-to-disconnect = []
    console.info "[%s] created" @name
 
    @port = chrome.runtime.connect { name: @name } if not @port
 
    @port.on-message.add-listener (message) !~>
      console.info "[%s] message received %O", @name, message
      return if not message.action
      @listening-to-receive
        |> each (<| message.action, (message.message or null))
 
    @port.on-disconnect.add-listener !~>
      @listening-to-disconnect
      |> each (<| null)
 
  post: (route, message) ->
    console.info "[%s] message posted to %s %O", @name, route, message
    @port.post-message { action: route, message: message }
 
  receive: (fn) --> @listening-to-receive.push fn
 
  disconnect: (fn) --> @listening-to-disconnect.push fn

export class Router
  loopback: \loopback
 
  (@local) ->
    @ports = []
    @endpoints = []
    @watch @local unless not @local
 
  watch: (port) ->
    console.info "[%s] preparing" port.name
    port.receive (endpoint, message) ~>
      @receive endpoint, message
 
    port.disconnect ~>
      console.info "[%s] disconnected", port.name
      @ports = @ports 
      |> filter (.name isnt port.name)
 
  bind: (port) !->
    console.info "[%s] binded", port.name
    port = new Port port.name, port
    @watch port
    @ports.push port
 
  receive: (endpoint, message) ->
    path = endpoint / "/"
    route-name = null
 
    if path.length > 1
      [route-name, endpoint] = path
    else
      [endpoint] = path
 
    switch
    | endpoint and not route-name or route-name is @loopback and not @local =>
      @endpoints
      |> filter (.name is endpoint)
      |> each (.fn message)
    | route-name and endpoint =>
      @ports
      |> filter (.name is route-name)
      |> each (.post endpoint, message)
    #| otherwise => console.log "Uésli ta apachonadaum"
 
  post: (route, message) !->
    [route-name, endpoint] = route / "/"
 
    throw new Error "Declare endpoint with /" if not endpoint
 
    port = @ports 
    |> filter (.name == name) |> first
 
    switch
    | port   => port.post endpoint, message
    | @local => @local.post route, message
    | _      => throw new Error \Ooooooops
 
  on: (endpoint, fn) !->
    console.info '[%s] binding', endpoint
    @endpoints.push { name: endpoint, fn: fn }