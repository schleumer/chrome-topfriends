{ map, tail, head } = require 'prelude-ls'
{ Router } = require './router.ls'

console.info('started background at version', window.__version);

pageContentPort = null
popupPort = null

chrome.runtime.onMessage.addListener((msg) !->
  console.info(port.name, 'requested')
)

router = new Router()

router.on('test', (message) -> console.log(message))

chrome.runtime.onConnect.addListener ((port) !-> router.bind(port))


chrome.tabs.query {}, (tabs) ->
  tabs.forEach ((currentTab) ->
    chrome.browserAction.disable currentTab.id
    chrome.browserAction.setIcon {
      tabId: currentTab.id
      path: chrome.extension.getURL 'icons/19-disabled.png'
    })

chrome.tabs.query {url: "*://*.facebook.com/*"}, (tabs) ->
  tabs.forEach ((currentTab) ->
    chrome.browserAction.enable currentTab.id
    chrome.browserAction.setIcon {
      tabId: currentTab.id
      path: chrome.extension.getURL 'icons/19.png'
    })

changeIcon = ->
  # TODO: it's ugly and i'll find a better way
  chrome.tabs.query { active: true }, (tabs) ->
    tabs.forEach ((currentTab) ->
      chrome.browserAction.disable currentTab.id
      chrome.browserAction.setIcon {
        tabId: currentTab.id
        path: chrome.extension.getURL 'icons/19-disabled.png'
      })

  chrome.tabs.query { url: "*://*.facebook.com/*", active: true }, (tabs) ->
    tabs.forEach ((currentTab) ->
      chrome.browserAction.enable currentTab.id
      chrome.browserAction.setIcon {
        tabId: currentTab.id
        path: chrome.extension.getURL 'icons/19.png'
      })

#listen for new tab to be activated
chrome.tabs.onActivated.addListener ((activeInfo) -> changeIcon!)

#listen for current tab to be changed
chrome.tabs.onUpdated.addListener ((tabId, changeInfo, tab) -> changeIcon!)