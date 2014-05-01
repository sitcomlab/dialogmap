angular.module("SustainabilityApp").controller "MapController", [
  "$scope"
  "$compile"
  "leafletData"
  "Contribution"
  ($scope, $compile, leafletData, Contribution) ->
    L.Icon.Default.imagePath = 'assets/'
    angular.extend $scope,
      # leaflet-directive stuff
      muenster:
        lat: 51.96
        lng: 7.62
        zoom: 14
      controls:
        draw:
          options:
            draw:
              polyline: false
              circle: false
      events:
        map:
          enable: ['moveend', 'draw:created','click','popupopen']
          logic: 'emit'
      tiles:
        url: 'http://osm-bright-ms.herokuapp.com/v2/osmbright/{z}/{x}/{y}.png'
      geojson:
        data: { "type": "FeatureCollection", "features": [] }
        style:
          fillColor: "green",
          weight: 2,
          opacity: 1,
          color: 'white',
          dashArray: '3',
          fillOpacity: 0.7
        onEachFeature: (feature, layer) ->
          #Create get the view template
          popupContent = "<div ng-include=\"'popupcontent.html'\"></div>"

          layer.bindPopup(popupContent,{
            minWidth: 250,
            feature: feature
          })
          return

      updateGeoJSON: ->
        $scope.map_main.then (map) ->
          bbox = map.getBounds().pad(1.005).toBBoxString()
          Contribution.query({bbox: bbox}).then (cts) ->
            fcollection =
              type: 'FeatureCollection'
              features: []
            for c in cts
              do ->
                if c.features.length > 0
                  for f in c.features
                    do ->
                      fcollection.features.push f
                      return
                return
            $scope.geojson =
              style: $scope.geojson.style
              onEachFeature: $scope.geojson.onEachFeature
              data: fcollection
            return
          return
        return

      # Contribution state
      composing: false
      # Map Object use with .then (map) ->
      map_main: leafletData.getMap('map_main')

      # Contribution Object
      newContribution:
        omfg: ['wurst']
        start: ->
          @reset()
          $scope.composing = true
          return
        abort: ->
          console.log @description
          @reset()
          $scope.composing = false
          return
        reset: ->
          @title = ''
          @description = {}
          $scope.drawControl.options.edit.featureGroup.clearLayers()
          return
        submit: ->
          @features_attributes = ( { "geojson": feature } for feature in $scope.drawControl.options.edit.featureGroup.toGeoJSON().features)
          new Contribution(@).create().then (data) ->
            temp = $scope.geojson
            $scope.geojson = {}
            $scope.geojson.data =
              type: "FeatureCollection"
              features: []
            for feature in data.featuresAttributes
              do ->
                $scope.geojson.data.features.push feature.geojson
                return
            for feature in temp.data.features
              do ->
                $scope.geojson.data.features.push feature
            return
          @reset()
          return

    # init stuff
    #$scope.updateGeoJSON()
    $scope.$on 'leafletDirectiveMap.moveend', (evt) ->
      $scope.updateGeoJSON()
      return
    $scope.$on 'leafletDirectiveMap.draw:created', (evt,leafletEvent) ->
      $scope.composing = true
      layer = leafletEvent.leafletEvent.layer
      id = layer._leaflet_id
      layer.options.properties = {}
      popupContent = $compile('<div description-area ng_model="popups.description_'+id+'" highlights="popups.highlights_'+id+'"></div>')($scope)
      layer.bindPopup(popupContent[0],{minWidth: 250}).openPopup();
      $scope.$watch 'popups.description_'+id, (value) ->
        layer.options.properties.title = value
        return
      return
    $scope.$on 'leafletDirectiveMap.popupopen', (evt, leafletEvent) ->
      feature = leafletEvent.leafletEvent.popup.options.feature;

      newScope = $scope.$new()
      newScope.feature = feature.properties

      $compile(leafletEvent.leafletEvent.popup._contentNode)(newScope)
      console.log $compile(leafletEvent.leafletEvent.popup._content)($scope)

      return
    $scope.$on 'leafletDirectiveMap.click', (evt, leafletEvent) ->
      console.log leafletEvent
      return
    return
]
