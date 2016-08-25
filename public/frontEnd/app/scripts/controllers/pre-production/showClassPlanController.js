/**
 * Created by fr3d0 on 7/31/16.
 */
'use strict';
app.controller("showClassPlanController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', 'NgTableParams', '$filter',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, NgTableParams, $filter){
        var getClassesPlan = function(){
            dawProcessManagerService.getClassPlan($stateParams.id, function (response)  {
                $scope.cp = response.data;
                $scope.tableParams = new NgTableParams({},{
                    filterOptions: { filterLayout: "horizontal" },
                    dataset: response.data.vdms
                });
                $scope.historyTable = new NgTableParams({
                    sorting: {
                        created_at: 'desc'
                    }
                },{
                    filterOptions: { filterLayout: "horizontal" },
                    dataset: response.data.changes
                });
            }, function(error) {
                alert(error);
            })
        };

        $scope.states = [{statusIng: 'not received', statusSpa: 'No recibido'}, {statusIng: 'received', statusSpa: 'Recibido'}, {statusIng: 'processed', statusSpa: 'Procesado'}];

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
                        title: "Justifique",
                        text: "Por que desea eliminar el mdt del video " + element.videoId,
                        type: "question",
                        showCancelButton: true,
                        confirmButtonText: "OK",
                        input: 'textarea'

                    }).then(function(text) {
                        element.justification = text;
                        dawProcessManagerService.deleteVdm(element, function(response){
                            swal({
                                title: "Exitoso",
                                text: "Se ha eliminado el MDT del video " + response.data.videoId,
                                type: 'success',
                                confirmButtonText: "OK"
                            });
                            element.id = response.data.id;
                            element.videoId = response.data.videoId;
                            element.writable = false;
                            array.splice(array.indexOf(element), 1);
                        }, function(error){
                            console.log(error)
                        })
                    }, function(){});
                }else{
                    array.splice(array.indexOf(element), 1);
                }
            }
        };

        $scope.saveVdm = function(vdm, array){
            $scope.disableSave = true;
            $("body").css("cursor", "progress");
            if (vdm != null){
                vdm.role = localStorageService.get('currentRole');
                if(vdm.id != null){
                    dawProcessManagerService.updateVdm(vdm, function (response){
                        swal({
                            title: "Exitoso",
                            text: "Se ha actualizado el MDT del video " + response.data.videoId,
                            type: 'success',
                            confirmButtonText: "OK",
                            confirmButtonColor: "lightskyblue"
                        });
                        $scope.disableSave = false;
                        $("body").css("cursor", "default");
                        if (response.data.designDept != null){
                            vdm.designDept = response.data.designDept;
                        }
                        if (response.data.postProdDept != null){
                            vdm.postProdDept = response.data.postProdDept;
                        }
                        vdm.writable = false;
                    }, function(error){
                        $scope.disableSave = false;
                        $("body").css("cursor", "default");
                        console.log(error)
                    })
                }else{
                    $scope.disableSave = false;
                    $("body").css("cursor", "default");

                    swal({
                        title: 'Justificar creacion',
                        input: 'textarea',
                        type: 'question',
                        showCancelButton: true
                    }).then(function(text) {
                        $scope.disableSave = true;
                        $("body").css("cursor", "progress");
                        vdm.justification = text;
                        dawProcessManagerService.addVdm(vdm, function(response){
                            swal({
                                title: "Exitoso",
                                text: "Se ha guardado el MDT del video " + response.data.videoId,
                                type: 'success',
                                confirmButtonText: "OK"
                            });
                            $scope.disableSave = false;
                            $("body").css("cursor", "default");
                            vdm.id = response.data.id;
                            vdm.videoId = response.data.videoId;
                            vdm.writable = false;
                        }, function(error){
                            $scope.disableSave = false;
                            $("body").css("cursor", "default");
                            console.log(error)
                        })
                    }, function(){
                        $scope.disableSave = false;
                        $("body").css("cursor", "default");
                    });

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
        
        getClassesPlan();

    }]);
