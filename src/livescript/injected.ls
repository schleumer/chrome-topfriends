# Hey, if you are a Facebook's developer or employee, please,
# CREATE A FUCKING MESSAGE_COUNT FIELD ON GRAPH API
# thanks :)

{ Port, Router } = require './router.ls'


# YEA, WE LOVE HARDCODE
requestCounter = (cb) ->
  http = new XMLHttpRequest
  url = 'https://www.facebook.com/ajax/mercury/threadlist_info.php'
  http.open 'POST', url, true
  fbDtsg = document.documentElement.innerHTML.match(/\{\"token\"\:\"(.*?)\"[\}\,]/).1
  
  if !fbDtsg
    cb(null, new Error("not ok [sad face]"))
    return
  
  params = 'client=web_messenger&inbox[offset]=0&inbox[limit]=25&inbox[filter]&__a=1&fb_dtsg=' + fbDtsg
  
  http.setRequestHeader 'Content-type', 'application/x-www-form-urlencoded'
  
  http.onreadystatechange = -> 
    if http.readyState is 4 
      if http.status is 200
        try
          data = JSON.parse(http.responseText.replace(/^for.*?\{/, '{'))
          if data.payload and data.payload.threads and data.payload.participants
            cb(data.payload, null)
        catch ex
          cb(null, ex)
      else
        cb(null, new Error("not ok [sad face]"))
  http.send params

port = new Port('content')
router = new Router(port)

router.on('ping', (message) -> 
  router.post('popup/pong', { message: ':)' }))

router.on('requestCounter', (message) ->
  requestCounter((info, err) ->
    router.post('popup/responseCounter', err or info)))

