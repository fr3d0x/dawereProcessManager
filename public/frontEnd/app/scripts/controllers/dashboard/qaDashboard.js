/**
 * Created by fr3d0 on 5/4/17.
 */
'use strict';
app.controller("qaDashboard",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService','NgTableParams', '$rootScope',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService,NgTableParams, $rootScope){

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

        $scope.activateQaProgress = function(){
            $scope.progressQaActive = true;
            $scope.progressQaAnalystsActive = false;
            getProgress('qa');
        };
        $scope.activateQaAnalystsProgress = function(){
            $scope.progressQaActive = false;
            $scope.progressQaAnalystsActive = true;
            getProgress('qa-analysts');
        };
        $scope.reloadProgress = function () {
            if($scope.progressQaActive){
                $scope.activateQaProgress()
            }
            if($scope.progressQaAnalystsActive){
                $scope.activateQaAnalystsProgress()
            }
        };
        $scope.activateQaProgress();

    }]);