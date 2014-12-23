angular.module 'chart2-main',['ngRoute']

  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'main/main.html'
        controller: 'MainCtrl'

  .controller 'MainCtrl', ($scope) ->
    $scope.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma',
      'Coffeescript',
      'Less',
      'Jade'
    ]