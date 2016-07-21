'use strict';

/**
 * @ngdoc function
 * @description
 * # MainCtrl
 * Controller of the app
 */

  app.controller('MainCtrl',['$scope','$http', '$translate',function ($scope, $http, $translate) {

    $scope.changeLanguage = function (langKey) {
      $translate.use(langKey);
      $scope.currentLanguage = langKey;
    };
    $scope.currentLanguage = $translate.proposedLanguage() || $translate.use();
  }]);
