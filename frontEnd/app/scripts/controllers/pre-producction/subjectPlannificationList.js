/**
 * Created by fr3d0 on 26/07/16.
 */
'use strict';
app.controller("subjectPlannificationListController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', 'NgTableParams', '$filter',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, NgTableParams, $filter){
        var subjectsPlaning = function(){
            dawProcessManagerService.getSubjectsPlaning(function (response)  {
                $scope.spList = response.data;
            }, function(error) {
                alert(error);
            })
        };


        subjectsPlaning();
    }]);
