/**
 * Created by fr3d0 on 28/07/16.
 */
'use strict';
app.controller("dawereVdmsController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', 'NgTableParams', '$filter',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, NgTableParams, $filter){
        var getVdms = function(){
            dawProcessManagerService.getDawereVdms(function (response)  {
                if (response.data.length < 1){
                    response.data.push({
                        id: 0,
                        videoId: null,
                        videoTittle: null,
                        videoContent: null,
                        status: null,
                        comments: null,
                        description: null,
                        writable: true
                    })
                }
                $scope.vdms = response.data;
                $scope.tableParams = new NgTableParams({},{
                    filterOptions: { filterLayout: "horizontal" },
                    dataset: response.data
                });
            }, function(error) {
                alert(error);
            })
        };

        $scope.states = [{statusIng: 'recorded', statusSpa: 'grabado'}, {statusIng: 'not recorded', statusSpa: 'no grabado'}];

        $scope.add = function(vdm, data){
            data.splice(data.indexOf(vdm)+1, 0, {
                cp: vdm.cp,
                videoId: null,
                videoTittle: null,
                videoContent: null,
                status: null,
                comments: null,
                description: null,
                writable: true,
                previewsIndex: data.indexOf(vdm)
            });
        };

        $scope.editRow = function(vdm){
            vdm.writable = true;
        };

        $scope.remove = function(element, array){
            if (element != null){
                if(element.id != null && element.id != 0){
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
                    if (array.indexOf(element) != 0){
                        array.splice(array.indexOf(element), 1);
                    }
                }
            }
        };

        $scope.saveVdm = function(vdm, array){
            if (vdm != null){
                if(vdm.id != null && vdm.id != 0){
                    dawProcessManagerService.updateVdm(vdm, function (response){
                        swal({
                            title: "Exitoso",
                            text: "Se ha actualizado el MDT del video " + response.data.videoId,
                            type: 'success',
                            confirmButtonText: "OK",
                            confirmButtonColor: "lightskyblue"
                        });
                        vdm.writable = false;
                    }, function(error){
                        console.log(error)
                    })
                }else{
                    swal({
                        title: 'Justificar creacion',
                        input: 'textarea',
                        type: 'question',
                        showCancelButton: true
                    }).then(function(text) {
                        vdm.justification = text;
                        dawProcessManagerService.addVdm(vdm, function(response){
                            swal({
                                title: "Exitoso",
                                text: "Se ha guardado el MDT del video " + response.data.videoId,
                                type: 'success',
                                confirmButtonText: "OK"
                            });
                            vdm.id = response.data.id;
                            vdm.videoId = response.data.videoId;
                            vdm.writable = false;
                            array.splice(vdm.previewsIndex+1, 0,  vdm);
                        }, function(error){
                            console.log(error)
                        })
                    }, function(){});

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