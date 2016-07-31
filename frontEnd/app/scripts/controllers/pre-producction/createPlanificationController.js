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
        $scope.add = function(arr){
            arr.push({
                meGeneralObjective: null,
                meSpecificObjective: null,
                meSpecificObjDesc: null,
                topicName: null,
                videos: null
            });
        };
        
        $scope.remove = function (item, arr) {
            arr.splice(arr.indexOf(item), 1);
        };

        $scope.save = function(data, cps){
            $scope.disableBtn = true;
            var correctPetition = true;
            if (cps == null){
                correctPetition = false;
            }
            if (data.teacher == null){
                correctPetition = false
            }
            if (data.subjectId == null){
                correctPetition = false
            }
            if (correctPetition){
                data.cps = cps;
                dawProcessManagerService.saveSubjectPlaning(data, function () {
                    swal({
                        title: "Exitoso",
                        text: "Plan de clases creado correctamente",
                        type: "success",
                        confirmButtonText: "OK"
                    }).then(function () {
                        $state.go('app.dashboard');
                    }, function(){});
                }, function (error) {
                    console.log(error)
                })
            }else{
                swal({
                    title: "Advertencia",
                    text: "Faltan datos para la creacion correcta del plan de clases",
                    type: "warning",
                    confirmButtonText: "OK"
                });
                $scope.disableBtn = false;
            }

        };

        getGradeWithSubjects();
}]);