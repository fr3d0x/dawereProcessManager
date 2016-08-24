/**
 * Created by fr3d0 on 8/22/16.
 */
'use strict';
app.controller("designerDashboard",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService','NgTableParams',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService,NgTableParams){

        var getGlobalProgress = function(){
            dawProcessManagerService.getGlobalProgress(localStorageService.get('currentRole'), function (response)  {
                $scope.progress = response.data;
            }, function(error) {
                alert(error);
            })
        };

        getGlobalProgress();

    }]);