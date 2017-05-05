/**
 * Created by fr3d0 on 8/22/16.
 */
'use strict';
app.controller("postProducerDashboard",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService','NgTableParams', '$rootScope',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService,NgTableParams, $rootScope){

        var getProgress = function(){
            $rootScope.setLoader(true);
            dawProcessManagerService.getEmployeeProgress(localStorageService.get('currentRole'), function (response)  {
                $scope.progress = response.data;
                $rootScope.setLoader(false);
            }, function(error) {
                $rootScope.setLoader(false);
                alert(error);
            })
        };

        getProgress();

    }]);