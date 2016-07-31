/**
 * Created by hector on 29/07/16.
 */
'use strict';
app.controller("createPlanificationController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', 'NgTableParams', '$filter',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, NgTableParams, $filter){
        $scope.completeGrades = [];
        $scope.toggle = false;
        $scope.cps = [];
        $scope.toggleAdd = false;
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
                    if (i == numberOfTopics){
                        $scope.toggleAdd = true;
                    }else {
                        $scope.toggleAdd = false;
                    }
                }
                if (i == numberOfTopics){
                    $scope.toggleAdd = true;
                }else {
                    $scope.toggleAdd = false;
                }
                $scope.toggle = true;
            }else{
                swal({
                    title: "Numero de videos invalidos",
                    text: "Coloque el numero de videos mayor a 0 (cero).",
                    type: "warning",
                    confirmButtonText: "OK"
                })
            }
        };
        $scope.addCp = function () {
            
        };
        $scope.removeCp = function () {
            
        };

        getGradeWithSubjects();
}]);