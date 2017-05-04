/**
 * Created by fr3d0 on 5/3/17.
 */
'use strict';
app.controller("productManagerDashboard",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService','NgTableParams',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService,NgTableParams){

        $scope.progressContentActive = false;
        $scope.progressContentAnalystsActive = false;
        $scope.progressProductionActive = false;
        $scope.progressEditorsActive = false;
        $scope.progressDesignActive = false;
        $scope.progressDesignersActive = false;
        $scope.progressPostProductionActive = false;
        $scope.progressPostProducersActive = false;

        var getProgress = function(type){
            if(role != null && type != null){
                $rootScope.setLoader(true);
                dawProcessManagerService.getGlobalProgress(localStorageService.get('currentRole'), type,function (response)  {
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
            $scope.progressProductionActive = false;
            $scope.progressEditorsActive = false;
            $scope.progressDesignActive = false;
            $scope.progressDesignersActive = false;
            $scope.progressPostProductionActive = false;
            $scope.progressPostProducersActive = false;
            getProgress('content_department');
        };
        $scope.activateContentAnalystsProgress = function(){
            $scope.progressContentActive = false;
            $scope.progressContentAnalystsActive = true;
            $scope.progressProductionActive = false;
            $scope.progressEditorsActive = false;
            $scope.progressDesignActive = false;
            $scope.progressDesignersActive = false;
            $scope.progressPostProductionActive = false;
            $scope.progressPostProducersActive = false;
            getProgress('content_analysts');
        };
        $scope.activateProductionProgress = function(){
            $scope.progressContentActive = false;
            $scope.progressContentAnalystsActive = false;
            $scope.progressProductionActive = true;
            $scope.progressEditorsActive = false;
            $scope.progressDesignActive = false;
            $scope.progressDesignersActive = false;
            $scope.progressPostProductionActive = false;
            $scope.progressPostProducersActive = false;
            getProgress('production');
        };
        $scope.activateEditorsProgress = function(){
            $scope.progressContentActive = false;
            $scope.progressContentAnalystsActive = false;
            $scope.progressProductionActive = false;
            $scope.progressEditorsActive = true;
            $scope.progressDesignActive = false;
            $scope.progressDesignersActive = false;
            $scope.progressPostProductionActive = false;
            $scope.progressPostProducersActive = false;
            getProgress('editors');
        };
        $scope.activateDesignProgress = function(){
            $scope.progressContentActive = false;
            $scope.progressContentAnalystsActive = false;
            $scope.progressProductionActive = false;
            $scope.progressEditorsActive = false;
            $scope.progressDesignActive = true;
            $scope.progressDesignersActive = false;
            $scope.progressPostProductionActive = false;
            $scope.progressPostProducersActive = false;
            getProgress('design');
        };
        $scope.activateDesignersProgress = function(){
            $scope.progressContentActive = false;
            $scope.progressContentAnalystsActive = false;
            $scope.progressProductionActive = false;
            $scope.progressEditorsActive = false;
            $scope.progressDesignActive = true;
            $scope.progressDesignersActive = false;
            $scope.progressPostProductionActive = false;
            $scope.progressPostProducersActive = false;
            getProgress('designers');
        };
    }]);