'use strict';

/**
 * @ngdoc function
 * @description
 * # MainCtrl
 * Controller of the app
 */

  app.controller('MainCtrl',['$scope','$http', '$translate', 'localStorageService', function ($scope, $http, $translate, localStorageService) {

    $scope.changeLanguage = function (langKey) {
      $translate.use(langKey);
      $scope.currentLanguage = langKey;
    };
    $scope.currentLanguage = $translate.proposedLanguage() || $translate.use();

    if(localStorageService.get('token')){
      if($rootScope.currentUser == null){
        $rootScope.currentUser = localStorageService.get('currentUser');
      }
    }else{
      $state.go('core.login');
    }
  }]);
