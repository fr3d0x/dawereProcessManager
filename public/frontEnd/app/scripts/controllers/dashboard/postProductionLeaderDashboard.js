/**
 * Created by fr3d0 on 8/22/16.
 */
'use strict';
app.controller("postProductionLeaderDashboard",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService','NgTableParams', '$rootScope',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService,NgTableParams, $rootScope){

        $scope.progressPostProductionActive = false;
        $scope.progressPostProducersActive = false;
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

        $scope.activatePostProductionProgress = function(){
            $scope.progressPostProductionActive = true;
            $scope.progressPostProducersActive = false;
            getProgress('post-production');
        };
        $scope.activatePostProducersProgress = function(){
            $scope.progressPostProductionActive = false;
            $scope.progressPostProducersActive = true;
            getProgress('post-producers');
        };

        $scope.reloadProgress = function () {
            if($scope.progressPostProductionActive){
                $scope.activatePostProductionProgress()
            }
            if($scope.progressPostProducersActive){
                $scope.activatePostProducersProgress()
            }
        };
        getProgress();

        $scope.activatePostProductionProgress();
    }]);