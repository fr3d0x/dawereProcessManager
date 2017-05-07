/**
 * Created by fr3d0 on 8/22/16.
 */
'use strict';
app.controller("designLeaderDashboard",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService','NgTableParams', '$rootScope',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService,NgTableParams, $rootScope){


        $scope.progressDesignActive = false;
        $scope.progressDesignersActive = false;
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

        $scope.activateDesignProgress = function(){
            $scope.progressDesignActive = true;
            $scope.progressDesignersActive = false;
            getProgress('design');
        };
        $scope.activateDesignersProgress = function(){
            $scope.progressDesignActive = false;
            $scope.progressDesignersActive = true;
            getProgress('designers');
        };

        $scope.reloadProgress = function () {
            if($scope.progressDesignActive){
                $scope.activateDesignProgress()
            }
            if($scope.progressDesignersActive){
                $scope.activateDesignersProgress()
            }
        };
        getProgress();

        $scope.activateDesignProgress();

    }]);