/**
 * Created by fr3d0 on 5/3/17.
 */
'use strict';
app.controller("productManagerDashboard",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService','NgTableParams', '$rootScope', '$filter',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService,NgTableParams, $rootScope, $filter){

        $scope.progressContentActive = false;
        $scope.progressContentAnalystsActive = false;
        $scope.progressProductionActive = false;
        $scope.progressEditionActive = false;
        $scope.progressEditorsActive = false;
        $scope.progressDesignActive = false;
        $scope.progressDesignersActive = false;
        $scope.progressPostProductionActive = false;
        $scope.progressPostProducersActive = false;
        $scope.progressQaActive = false;
        $scope.progressQaAnalystsActive = false;
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
            $scope.progressProductionActive = false;
            $scope.progressEditionActive = false;
            $scope.progressEditorsActive = false;
            $scope.progressDesignActive = false;
            $scope.progressDesignersActive = false;
            $scope.progressPostProductionActive = false;
            $scope.progressPostProducersActive = false;
            $scope.progressQaActive = false;
            $scope.progressQaAnalystsActive = false;
            getProgress('content_department');
        };
        $scope.activateContentAnalystsProgress = function(){
            $scope.progressContentActive = false;
            $scope.progressContentAnalystsActive = true;
            $scope.progressProductionActive = false;
            $scope.progressEditionActive = false;
            $scope.progressEditorsActive = false;
            $scope.progressDesignActive = false;
            $scope.progressDesignersActive = false;
            $scope.progressPostProductionActive = false;
            $scope.progressPostProducersActive = false;
            $scope.progressQaActive = false;
            $scope.progressQaAnalystsActive = false;
            getProgress('content_analysts');
        };
        $scope.activateProductionProgress = function(){
            $scope.progressContentActive = false;
            $scope.progressContentAnalystsActive = false;
            $scope.progressProductionActive = true;
            $scope.progressEditionActive = false;
            $scope.progressEditorsActive = false;
            $scope.progressDesignActive = false;
            $scope.progressDesignersActive = false;
            $scope.progressPostProductionActive = false;
            $scope.progressPostProducersActive = false;
            $scope.progressQaActive = false;
            $scope.progressQaAnalystsActive = false;
            getProgress('production');
        };
        $scope.activateEditionProgress = function(){
            $scope.progressContentActive = false;
            $scope.progressContentAnalystsActive = false;
            $scope.progressProductionActive = false;
            $scope.progressEditionActive = true;
            $scope.progressEditorsActive = false;
            $scope.progressDesignActive = false;
            $scope.progressDesignersActive = false;
            $scope.progressPostProductionActive = false;
            $scope.progressPostProducersActive = false;
            $scope.progressQaActive = false;
            $scope.progressQaAnalystsActive = false;
            getProgress('edition');
        };
        $scope.activateEditorsProgress = function(){
            $scope.progressContentActive = false;
            $scope.progressContentAnalystsActive = false;
            $scope.progressProductionActive = false;
            $scope.progressEditionActive = false;
            $scope.progressEditorsActive = true;
            $scope.progressDesignActive = false;
            $scope.progressDesignersActive = false;
            $scope.progressPostProductionActive = false;
            $scope.progressPostProducersActive = false;
            $scope.progressQaActive = false;
            $scope.progressQaAnalystsActive = false;
            getProgress('editors');
        };
        $scope.activateDesignProgress = function(){
            $scope.progressContentActive = false;
            $scope.progressContentAnalystsActive = false;
            $scope.progressProductionActive = false;
            $scope.progressEditionActive = false;
            $scope.progressEditorsActive = false;
            $scope.progressDesignActive = true;
            $scope.progressDesignersActive = false;
            $scope.progressPostProductionActive = false;
            $scope.progressPostProducersActive = false;
            $scope.progressQaActive = false;
            $scope.progressQaAnalystsActive = false;
            getProgress('design');
        };
        $scope.activateDesignersProgress = function(){
            $scope.progressContentActive = false;
            $scope.progressContentAnalystsActive = false;
            $scope.progressProductionActive = false;
            $scope.progressEditionActive = false;
            $scope.progressEditorsActive = false;
            $scope.progressDesignActive = false;
            $scope.progressDesignersActive = true;
            $scope.progressPostProductionActive = false;
            $scope.progressPostProducersActive = false;
            $scope.progressQaActive = false;
            $scope.progressQaAnalystsActive = false;
            getProgress('designers');
        };
        $scope.activatePostProductionProgress = function(){
            $scope.progressContentActive = false;
            $scope.progressContentAnalystsActive = false;
            $scope.progressProductionActive = false;
            $scope.progressEditionActive = false;
            $scope.progressEditorsActive = false;
            $scope.progressDesignActive = false;
            $scope.progressDesignersActive = false;
            $scope.progressPostProductionActive = true;
            $scope.progressPostProducersActive = false;
            $scope.progressQaActive = false;
            $scope.progressQaAnalystsActive = false;
            getProgress('post-production');
        };
        $scope.activatePostProducersProgress = function(){
            $scope.progressContentActive = false;
            $scope.progressContentAnalystsActive = false;
            $scope.progressProductionActive = false;
            $scope.progressEditionActive = false;
            $scope.progressEditorsActive = false;
            $scope.progressDesignActive = false;
            $scope.progressDesignersActive = false;
            $scope.progressPostProductionActive = false;
            $scope.progressPostProducersActive = true;
            $scope.progressQaActive = false;
            $scope.progressQaAnalystsActive = false;
            getProgress('post-producers');
        };
        $scope.activateQaProgress = function(){
            $scope.progressContentActive = false;
            $scope.progressContentAnalystsActive = false;
            $scope.progressProductionActive = false;
            $scope.progressEditionActive = false;
            $scope.progressEditorsActive = false;
            $scope.progressDesignActive = false;
            $scope.progressDesignersActive = false;
            $scope.progressPostProductionActive = false;
            $scope.progressPostProducersActive = false;
            $scope.progressQaActive = true;
            $scope.progressQaAnalystsActive = false;
            getProgress('qa');
        };
        $scope.activateQaAnalystsProgress = function(){
            $scope.progressContentActive = false;
            $scope.progressContentAnalystsActive = false;
            $scope.progressProductionActive = false;
            $scope.progressEditionActive = false;
            $scope.progressEditorsActive = false;
            $scope.progressDesignActive = false;
            $scope.progressDesignersActive = false;
            $scope.progressPostProductionActive = false;
            $scope.progressPostProducersActive = false;
            $scope.progressQaActive = false;
            $scope.progressQaAnalystsActive = true;
            getProgress('qa-analysts');
        };
        $scope.reloadProgress = function () {
          if($scope.progressContentActive){
              $scope.activateContentProgress();
          }
          if($scope.progressContentAnalystsActive){
              $scope.activateContentAnalystsProgress();
          }
          if($scope.progressProductionActive){
              $scope.activateProductionProgress();
          }
          if($scope.progressEditionActive){
              $scope.activateEditionProgress();
          }
          if($scope.progressEditorsActive){
              $scope.activateEditorsProgress();
          }
          if($scope.progressDesignActive){
              $scope.activateDesignProgress()
          }
          if($scope.progressDesignersActive){
              $scope.activateDesignersProgress()
          }
          if($scope.progressPostProductionActive){
              $scope.activatePostProductionProgress()
          }
          if($scope.progressPostProducersActive){
              $scope.activatePostProducersProgress()
          }
          if($scope.progressQaActive){
              $scope.activateQaProgress()
          }
          if($scope.progressQaAnalystsActive){
              $scope.activateQaAnalystsProgress()
          }
        };
        $scope.activateContentProgress();

    }]);