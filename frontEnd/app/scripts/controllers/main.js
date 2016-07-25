'use strict';

/**
 * @ngdoc function
 * @description
 * # MainCtrl
 * Controller of the app
 */

  app.controller('MainCtrl',['$scope','$http', 'localStorageService', '$window', '$state', '$rootScope', function ($scope, $http, localStorageService, $window, $state, $rootScope) {
    

    if(localStorageService.get('encodedToken')){
      if($rootScope.currentUser == null){
        $rootScope.currentUser = localStorageService.get('currentUser');
      }
    }else{
      $state.go('core.login');
    }
  }]);
