/**
 * Created by hector on 2/08/16.
 */
'use strict';
app.controller("productionDashboardController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService','NgTableParams',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService,NgTableParams){

        var getGlobalProgress = function(){
            dawProcessManagerService.getGlobalProgress(function (response)  {
                $scope.progress = response.data;
                $scope.grades = response.grades;
            }, function(error) {
                alert(error);
            })
        };

        $scope.examinateFile = function(file){
            var dataUrl;
            var fileReader = new FileReader();
            fileReader.readAsDataURL(file);
            fileReader.onload = function (e) {
                dataUrl = e.target.result;
                window.open(dataUrl);
            };

            return file


        };

        getGlobalProgress();

    }]);