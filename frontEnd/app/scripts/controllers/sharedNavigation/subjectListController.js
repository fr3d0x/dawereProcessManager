/**
 * Created by hector on 26/07/16.
 */
'use strict';
app.controller("subjectListController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', '$rootScope',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, $rootScope){

        var getSubjectList = function() {
            dawProcessManagerService.getSubjectList($stateParams.id, function (response) {
                $scope.subjects = response.data;
            }, function (error) {
                console.log(error);
            });   
        };
        getSubjectList();
    }]);
