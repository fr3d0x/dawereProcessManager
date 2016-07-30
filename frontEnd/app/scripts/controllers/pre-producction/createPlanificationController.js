/**
 * Created by hector on 29/07/16.
 */
'use strict';
app.controller("createPlanificationController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', 'NgTableParams', '$filter',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, NgTableParams, $filter){
        $scope.completeGrades = [];
        $scope.toggle = false;
        $scope.cps = [];
        var getGradeWithSubjects = function() {
            dawProcessManagerService.getGradesWithSubjects(function (response) {
                $scope.completeGrades = response.data;
            }, function (error) {
                console.log(error);
            });
        };

        $scope.generateClassesPlanification = function(numberOfTopics, cps){
            if (numberOfTopics>0){
                for (var i=0; i<numberOfTopics; i++){
                    cps.push({
                        meGeneralObjective:'',
                        meSpecificObjective:'',
                        meSpecificObjDesc:'',
                        topicName:'',
                        videos:''
                    });

                }
                $scope.toggle = true;
            }else{
                swal("Dato invalido","Debe agreagar mas de 1 tema.")
            }

        };

        getGradeWithSubjects();
}]);