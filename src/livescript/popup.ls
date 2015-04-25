require! 'angular'
require! 'angular-route'

{ Port, Router } = require './router.ls'

{ each, map, filter, first } = require 'prelude-ls'

app = angular.module 'ChromeTopfriends', ['ngRoute']

app.config ['$routeProvider', ($routeProvider) ->
  $routeProvider.when '/',
    templateUrl: 'templates/index.html',
    controller: 'IndexController'
  .otherwise(redirectTo: '/')
]

app.run ['$rootScope', ($rootScope) ->
  port = new Port('popup')
  router = new Router(port)

  $rootScope.requestCounter = ->
    router.post('content/requestCounter')
  
  router.on('responseCounter', (message) ->
    $rootScope.$broadcast('responseCounter', message))

  $rootScope.ping = ->
    router.post('content/ping')

  router.on('pong', ->
    $rootScope.$broadcast('pong', null))
]

app.controller('IndexController', 
['$scope', '$rootScope', '$timeout', ($scope, $rootScope, $timeout) ->
  $scope.loading = 1
  $scope.data = null
  $scope.is-shared-data-shown = false


  $scope.show-shared-data = ->
    # yeah
    $scope.is-shared-data-shown = not $scope.is-shared-data-shown

  $rootScope.$on('pong', -> 
    $rootScope.requestCounter!
    $scope.$apply(-> $scope.loading = 2))

  $timeout((-> 
    if $scope.loading == 1
      $scope.loading = 99), 3000)

  $rootScope.$on('responseCounter', (ev, data) -> 
    $scope.$apply(-> 
      $scope.loading = false
      $scope.data = data))

    # thread
    #  .thread_id
    #  .thread_fbid
    #  .other_user_fbid
    #  .last_action_id
    #  .participants
    #  .former_participants
    #  .snippet_has_attachment
    #  .is_forwarded_snippet
    #  .snippet_attachments
    #  .snippet_sender
    #  .unread_count
    #  .message_count
    #  .image_src
    #  .timestamp_absolute
    #  .timestamp_datetime
    #  .timestamp_relative
    #  .timestamp_time_passed
    #  .timestamp
    #  .server_timestamp
    #  .mute_settings
    #  .is_canonical_user
    #  .is_canonical
    #  .canonical_fbid
    #  .is_subscribed
    #  .folder
    #  .is_archived
    #  .mode
    #  .recipients_loadable
    #  .name_conversation_sheet_dismissed
    #  .has_email_participant
    #  .read_only


    # participant
    #  .fbid
    #  .gender
    #  .href
    #  .id
    #  .image_src
    #  .big_image_src
    #  .name
    #  .short_name
    #  .employee
    #  .is_employee_away
    #  .networks
    #  .type
    #  .vanity
    #  .is_friend
    #  .social_snippets
    #  .is_messenger_user

  $scope.getThreads = ->
    switch $scope.data
    | null      => []
    | otherwise => $scope.data.threads 
      |> filter (.participants.length < 3)
      |> map (.{participants, timestamp, message_count})
      |> each((thread) -> 
        thread.real-participants = 
          thread.participants 
            |> map ((p) -> 
              $scope.data.participants 
                |> filter (.id == p) |> first)
                |> map (.{fbid, gender, href, id, image_src, big_image_src, name, short_name}))

  $rootScope.ping!
])