/**
 * Created by fr3d0 on 5/3/17.
 */
'use strict';
app.controller("productManagerDashboard",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService','NgTableParams',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService,NgTableParams){

        var getGlobalProgress = function(){
            dawProcessManagerService.getGlobalProgress(localStorageService.get('currentRole'), function (response)  {
                $scope.progress = response.data;
                $scope.grades = response.grades;
            }, function(error) {
                alert(error);
            })
        };

        getGlobalProgress();

    }]);