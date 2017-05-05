/**
 * Created by hector on 2/08/16.
 */
'use strict';
app.controller("productionDashboard",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService','NgTableParams', '$rootScope',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService,NgTableParams, $rootScope){

        $scope.date = {
            from_date: null,
            to_date: null
        };
        var getProgress = function(type){
            if(type != null){
                $rootScope.setLoader(true);
                dawProcessManagerService.getGlobalProgress(localStorageService.get('currentRole'), type, $scope.date.from_date, $scope.date.to_date,function (response)  {
                    $rootScope.setLoader(false);
                    $scope.data = response.data;
                }, function(error) {
                    alert(error);
                })
            }
        };


        $scope.reloadProgress = function () {
            getProgress('production')
        };

        getProgress('production');

    }]);