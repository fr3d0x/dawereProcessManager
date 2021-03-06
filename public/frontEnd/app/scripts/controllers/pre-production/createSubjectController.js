/**
 * Created by hector on 29/07/16.
 */

app.controller("createSubjectController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', '$rootScope',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, $rootScope){
        $scope.subject = {};
        $scope.grade = {};
        
        var getGrades = function () {
            dawProcessManagerService.getGrades(function (response) {
                $scope.grades = response.data;
            }, function (error) {
                console.log(error)    
            })
            
        };
        
        var getSubjectList = function() {
            dawProcessManagerService.getSubjectList($stateParams.id, function (response) {
                $scope.subjects = response.data;
            }, function (error) {
                console.log(error);
            });
        };
        
        $scope.saveSubject = function (grade,subject) {
            $scope.disableBtn = true;
            if (grade != null && subject != null){
                data = {
                    grade: grade,
                    subject: subject
                };
                dawProcessManagerService.createSubject(data,function (response) {
                    if (response.status == "SUCCESS"){
                        swal({
                            title: "Exitoso",
                            text: "Se ha creado la materia exitosamente.",
                            type: "success",
                            confirmButtonText: "Aceptar",
                            confirmButtonColor: "lightskyblue"
                        }).then(function () {
                            $state.go('app.dashboard');
                        }, function(){});
                    }else{
                        swal({
                            title: "Fallido",
                            text: "No se ha podido crear la materia.",
                            type: "warning",
                            confirmButtonText: "Aceptar",
                            confirmButtonColor: "lightskyblue"
                        });
                    }
                }, function(error){
                    console.log(error)
                })
            }
        };
        getSubjectList();
        getGrades();
    }]);
