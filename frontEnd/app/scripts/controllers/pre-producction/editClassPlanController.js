/**
 * Created by fr3d0 on 27/07/16.
 */
'use strict';
app.controller("editClassPlanController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', 'NgTableParams', '$filter',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, NgTableParams, $filter){
        var getClassesPlan = function(){
            dawProcessManagerService.getClassPlan($stateParams.id, function (response)  {
                $scope.cp = response.data;
            }, function(error) {
                alert(error);
            })
        };
        
        getClassesPlan();
        
        $scope.remove = function(element, array){
            if (element != null){
                swal({
                        title: "Esta seguro",
                        text: "Seguro desea eliminar el MDT del video " + element.videoId,
                        type: "warning",
                        showCancelButton: false,
                        confirmButtonText: "OK",
                        closeOnConfirm: false,
                        closeOnCancel: true
                    },
                    function () {
                        array.splice(array.indexOf(element), 1);
                        dawProcessManagerService.deleteVdm(element.id, function(response){
                            swal({
                                title: "Exitoso",
                                text: "Se ha eliminado el MDT del video" + element.videoId,
                                type: "success",
                                confirmButtonText: "OK",
                                closeOnConfirm: true
                            })
                        }, function (error) {
                            console.log(error)
                        })
                    });
            }
        }

        $scope.add = function(array){
            if (array != null){
                array.push({
                    
                })
            }

        }
    }]);
