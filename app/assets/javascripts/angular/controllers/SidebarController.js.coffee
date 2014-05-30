angular.module("SustainabilityApp").controller "SidebarController", [
  "$scope"
  "Contribution"
  "User"
  "$compile"
  "$state"
  ($scope, Contribution, User, $compile, $state) ->
    angular.extend $scope,
      Contribution: Contribution
      User: User
      $state: $state
      startNewTopic: ->
        angular.element('.composing_container').remove()
        inputAreaHtml = $compile("<div class=\"composing_container\" ng-include=\"'contribution_input.html'\"></div>")($scope)
        angular.element('#new-topic-container').append(inputAreaHtml)
        Contribution.start()
        return

      startContributionHere: (id) ->
        angular.element('.composing_container').remove()

        inputAreaHtml = $compile("<div class=\"composing_container\" ng-include=\"'contribution_input.html'\"></div>")($scope)
        angular.element(".contribution_input_replace[data-id=#{id}]").append inputAreaHtml
        Contribution.start(id)
        return

    # $scope.$on '$stateChangeSuccess', (event, toState, toParams) ->
    #   if toState.name is 'contribution'
    #     Contribution.setCurrentContribution(toParams.id)
    #     # $scope.contribution = Contribution.currentContribution
    #
    #   console.log toState
    #   console.log toParams
    #   return
    return
]
