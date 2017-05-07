/**
 * Created by fr3d0 on 25/07/16.
 */

'use strict';
app.controller("preProductionDashboardController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService','NgTableParams', '$rootScope',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService,NgTableParams, $rootScope){

        $scope.progressContentActive = false;
        $scope.progressContentAnalystsActive = false;
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

        $scope.activateContentProgress = function(){
            $scope.progressContentActive = true;
            $scope.progressContentAnalystsActive = false;
            getProgress('content_department');
        };
        $scope.activateContentAnalystsProgress = function(){
            $scope.progressContentActive = false;
            $scope.progressContentAnalystsActive = true;
            getProgress('content_analysts');
        };
        $scope.reloadProgress = function () {
            if($scope.progressContentActive){
                $scope.activateContentProgress();
            }
            if($scope.progressContentAnalystsActive){
                $scope.activateContentAnalystsProgress();
            }
        };

        $scope.activateContentProgress();
    }]);