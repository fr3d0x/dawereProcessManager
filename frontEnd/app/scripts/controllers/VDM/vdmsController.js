/**
 * Created by fr3d0 on 28/07/16.
 */
'use strict';
app.controller("vdmsController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', 'NgTableParams', '$filter',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, NgTableParams, $filter){
        var getVdms = function(){
            dawProcessManagerService.getVdmsBySubject($stateParams.id, function (response)  {
                var data = response.data;
                $scope.subject = response.subject;
                $scope.tableParams = new NgTableParams({},{
                    filterOptions: { filterLayout: "horizontal" },
                    dataset: data
                });
            }, function(error) {
                alert(error);
            })
        };

        $scope.states = [{statusIng: 'not recieved', statusSpa: 'No recibido'}, {statusIng: 'recieved', statusSpa: 'Recibido'}, {statusIng: 'processed', statusSpa: 'Procesado'}];

        $scope.add = function(vdm, data){
            data.splice(data.indexOf(vdm)+1, 0, {
                cp: vdm.cp,
                videoId: null,
                videoTittle: null,
                videoContent: null,
                status: null,
                comments: null,
                description: null,
                writable: true
            });
        };
        
        $scope.editRow = function(vdm){
            vdm.writable = true;
        };

        $scope.remove = function(element, array){
            if (element != null){
                if(element.id != null){
                    swal({
                            title: "Esta seguro",
                            text: "Seguro desea eliminar el MDT del video " + element.videoId,
                            type: "warning",
                            showCancelButton: true,
                            confirmButtonText: "OK",
                            closeOnConfirm: false,
                            closeOnCancel: true
                        },
                        function () {
                            dawProcessManagerService.deleteVdm(element.id, function(response){
                                array.splice(array.indexOf(element), 1);
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
                }else{
                    array.splice(array.indexOf(element), 1);
                }
            }
        };

        $scope.saveVdm = function(vdm){
            if (vdm != null){
                if(vdm.id != null){

                }else{
                    dawProcessManagerService.addVdm(vdm, function(response){
                        swal({
                            title: "Exitoso",
                            text: "Se ha guardado el MDT del video " + response.data.videoId,
                            type: "success",
                            confirmButtonText: "OK",
                            closeOnConfirm: true
                        });
                        vdm.id = response.data.id;
                        vdm.videoId = response.data.videoId;
                        vdm.writable = false
                    }, function(error){
                        console.log(error)
                    })
                }

            }
        };
        
        $scope.close = function(vdm, arr){
            if(vdm.id != null){
                vdm.writable = false;
            }else{
                arr.splice(arr.indexOf(vdm), 1)
            }

        };
        getVdms();
    }]);
