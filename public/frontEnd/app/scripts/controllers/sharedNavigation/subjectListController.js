/**
 * Created by hector on 26/07/16.
 */
'use strict';
app.controller("subjectListController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', '$rootScope',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, $rootScope){

        $scope.disableAssign = false;
        var getemployeesJson = function (employees) {
            var json = {};
            for (var i = 0; i<employees.length; i++){
                var name = employees[i].name;
                json[employees[i].id] = name;
            }
            return json
        };

        var getSubjectList = function() {
            dawProcessManagerService.getSubjectList($stateParams.id, function (response) {
                $scope.subjects = response.data;
                $scope.employees = response.employees;
            }, function (error) {
                console.log(error);
            });   
        };
        
        $scope.assignSubject = function(subject){
            if ($scope.disableAssign != true){
                swal({
                    title: 'Seleccione analista para asignar la materia',
                    input: 'select',
                    inputOptions: getemployeesJson($scope.employees),
                    inputPlaceholder: 'Seleccione',
                    showCancelButton: true,
                    inputValidator: function(value) {
                        return new Promise(function(resolve, reject) {
                            if (value != '') {
                                resolve();
                            } else {
                                reject('Seleccione un analista o presione cancelar)');
                            }
                        });
                    }
                }).then(function(result){
                    if(result != null){
                        subject.user_id = result;
                        $("body").css("cursor", "progress");
                        $scope.disableAssign = true;
                        dawProcessManagerService.assignSubject(subject, function (response){
                            $("body").css("cursor", "default");
                            $scope.disableAssign = false;
                            swal({
                                title: "Exitoso",
                                text: "La materia ha sido asignada a " + response.data.user.name,
                                type: 'success',
                                confirmButtonText: "OK",
                                confirmButtonColor: "lightskyblue"
                            });
                            subject.user = response.data.user;

                        }, function(error){
                            console.log(error);
                        });
                    }
                }, function(){
                    $("body").css("cursor", "default");
                    $scope.disableAssign = false;
                })
            }

        };
        getSubjectList();
    }]);
