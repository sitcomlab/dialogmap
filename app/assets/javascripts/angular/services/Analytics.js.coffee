###*
Analytics tracking

@author Maikel Daloo
@date 22th March 2013
@link https://gist.github.com/maikeldaloo/5218712

###
angular.module('DialogMapApp').factory "Analytics", [
  "$window"
  "leafletData"
  "$rootScope"
  "$http"
  "User"
  ($window, leafletData, $rootScope, $http, User) ->
    PROJECT_ID = '554ca9ae59949a0dab9f8ac9'
    EVENT_COLLECTION = 'tracking'
    WRITE_KEY = '0ca364f67bb792947fe09205250c735559c193ce0b5e7c2e6859e73cad6f81379ddf2b4eb3e44254f29ba0f72244a51979b3079d3870c151ed9d2d889605580803a100e07e78a9ea8618a4cb71d3b50879e1509d763f6b5d65d5fc663f2e3ee39fd601b9a2d97b76c3f8af3a52d5e312'
    url = "https://api.keen.io/3.0/projects/#{PROJECT_ID}/events/#{EVENT_COLLECTION}?api_key=#{WRITE_KEY}"

    # init page visibility stuff
    hidden = undefined
    visibilityChange = undefined
    if typeof document.hidden != 'undefined'
      hidden = 'hidden'
      visibilityChange = 'visibilitychange'
    else if typeof document.mozHidden != 'undefined'
      hidden = 'mozHidden'
      visibilityChange = 'mozvisibilitychange'
    else if typeof document.msHidden != 'undefined'
      hidden = 'msHidden'
      visibilityChange = 'msvisibilitychange'
    else if typeof document.webkitHidden != 'undefined'
      hidden = 'webkitHidden'
      visibilityChange = 'webkitvisibilitychange'

    handleVisibilityChange = ->
      if document[hidden]
        tracking.trackEvent 'pageVisibilityChange', { pageVisibility: 'hidden' }
      else
        tracking.trackEvent 'pageVisibilityChange', { pageVisibility: 'visible' }
      return

    if typeof document.addEventListener != 'undefined' or typeof document[hidden] != 'undefined'
      document.addEventListener visibilityChange, handleVisibilityChange, false
      $window.addEventListener 'unload', (->
        tracking.trackEvent 'pageUnload'
        return
      ), false

    tracking = (

      ###*
      Tracks a custom event.
      This is useful for tracking specific actions, such as how many times
      a video is played.

      @param  {string} category Required category name
      @param  {string} action Required action
      @param  {json} label Optional label

      @return {boolean}
      ###
      trackEvent: (action, data) ->
        if $window.scientifictracking && action.length
          return leafletData.getMap('map_main').then (map) ->
            if !data?
              data = {}
            data.map =
              zoom: map.getZoom()
              bounds:
                sw: map.getBounds()._southWest
                ne: map.getBounds()._northEast
            data.fingerprint = $rootScope.browserFingerprintForGa
            if User.user?
              data.user = User.user.id
            data.timestamp = Date.now()
            data.action = action
            $http.post(url, data)
            # $window.ga "send", "event", category, action, JSON.stringify(label), { useBeacon: true }
            true
        false
    )
    return tracking
]
