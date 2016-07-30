/**
 * Created by hector on 29/07/16.
 */
'use strict';
app.controller("createPlanificationController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', 'NgTableParams', '$filter',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, NgTableParams, $filter){

        var getGradeWithSubjects = function() {
            dawProcessManagerService.getGradesWithSubjects(function (response) {
                $scope.grades = response.data;
            }, function (error) {
                swal(error, 'error');
            });
        };

        getGradeWithSubjects();
}]);