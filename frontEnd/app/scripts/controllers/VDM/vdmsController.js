/**
 * Created by fr3d0 on 28/07/16.
 */
'use strict';
app.controller("vdmsController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', 'NgTableParams', '$filter',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, NgTableParams, $filter){
        var getVdms = function(){
            dawProcessManagerService.getVdmsBySubject($stateParams.id, function (response)  {
                var tableData = [];
                $scope.subject = response.subject;
                $scope.employees = response.employees;
                switch (localStorageService.get('currentRole')){
                    case 'contentLeader':
                        tableData = response.data;
                        break;
                    case 'production':
                        tableData = response.production;
                        break;
                }
                $scope.tableParams = new NgTableParams({
                    sorting: {
                    videoNumber: 'asc'
                    }
                },{
                    filterOptions: { filterLayout: "horizontal" },
                    dataset: tableData
                });
            }, function(error) {
                alert(error);
            })
        };

        $scope.states = [{statusIng: 'not received', statusSpa: 'no recibido'}, {statusIng: 'received', statusSpa: 'recibido'}, {statusIng: 'processed', statusSpa: 'procesado'}];

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
                            array.splice(vdm.previewsIndex+1, 0,  vdm);
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

        $scope.saveVdmProd = function(vdm, file){
            $scope.disableProdSave = true;
            $("body").css("cursor", "progress !important");
            if (vdm != null){
                var mesage = '';
                var incomplete = false;
                if (vdm.intro != vdm.prodDept.intro && vdm.conclu != vdm.prodDept.conclu && vdm.vidDev == vdm.prodDept.vidDev){
                    if (vdm.prodDept.vidDev != true){
                        mesage = "Grabacion incompleta solo introduccion y conclucion";
                        incomplete = true
                    }
                }
                if (vdm.intro != vdm.prodDept.intro && vdm.conclu == vdm.prodDept.conclu && vdm.vidDev != vdm.prodDept.vidDev){
                    if (vdm.prodDept.conclu != true){
                        mesage = "Grabacion incompleta solo introduccion y desarrollo";
                        incomplete = true
                    }
                }
                if (vdm.intro == vdm.prodDept.intro && vdm.conclu != vdm.prodDept.conclu && vdm.vidDev != vdm.prodDept.vidDev){
                    if (vdm.intro == vdm.prodDept.intro != true){
                        mesage = "Grabacion incompleta solo conclusion y desarrollo";
                        incomplete = true
                    }
                }
                if (vdm.intro != vdm.prodDept.intro && vdm.conclu == vdm.prodDept.conclu && vdm.vidDev == vdm.prodDept.vidDev){
                    if (vdm.intro == vdm.prodDept.conclu != true && vdm.prodDept.vidDev != true){
                        mesage = "Grabacion incompleta solo introduccion";
                        incomplete = true
                    }
                }
                if (vdm.intro == vdm.prodDept.intro && vdm.conclu != vdm.prodDept.conclu && vdm.vidDev == vdm.prodDept.vidDev){
                    if (vdm.intro == vdm.prodDept.intro != true && vdm.prodDept.vidDev != true){
                        mesage = "Grabacion incompleta solo conclusion";
                        incomplete = true
                    }
                }
                if (vdm.intro == vdm.prodDept.intro && vdm.conclu == vdm.prodDept.conclu && vdm.vidDev != vdm.prodDept.vidDev){
                    if (vdm.intro == vdm.prodDept.intro != true && vdm.prodDept.conclu != true) {
                        mesage = "Grabacion incompleta solo desarrollo";
                        incomplete = true
                    }

                }
                if (file != undefined && file != null ){
                    var fileMessage = '';
                    var valid = true;
                    var fileReader = new FileReader();
                    fileReader.readAsDataURL(file);
                    fileReader.onload = function (e) {
                        var dataUrl;
                        dataUrl = e.target.result;
                        vdm.prodDept.script = dataUrl.split(',')[1];
                        if (file.size > 1000000){
                            fileMessage = "El archivo es demasiado grande para ser guardado, por favor asegurese que los guiones no pesen mas de 1MB";
                            valid = false;
                        }
                        if (file.type != 'application/pdf'){
                            fileMessage = "Los guiones deben ser de tipo .pdf para ser guardados";
                            valid = false;
                        }
                        if (valid == false){
                            $("body").css("cursor", "default");
                            $scope.disableProdSave = false;
                            swal({
                                title: 'Aviso',
                                text: fileMessage,
                                type: 'warning',
                                showCancelButton: false,
                                confirmButtonText: "OK",
                                confirmButtonColor: "lightcoral"
                            })
                        }else{
                            if (incomplete){
                                $scope.disableProdSave = false;
                                $("body").css("cursor", "default");
                                swal({
                                    title: 'Justificar',
                                    text: mesage,
                                    input: 'textarea',
                                    type: 'question',
                                    showCancelButton: true
                                }).then(function(text){
                                    $scope.disableProdSave = true;
                                    $("body").css("cursor", "progress");
                                    vdm.prodDept.justification = text;
                                    dawProcessManagerService.updateVdm(vdm, function (response){
                                        swal({
                                            title: "Exitoso",
                                            text: "Se ha actualizado el MDT del video " + response.data.videoId,
                                            type: 'success',
                                            confirmButtonText: "OK",
                                            confirmButtonColor: "lightskyblue"
                                        });
                                        $("body").css("cursor", "default");
                                        $scope.disableProdSave = false;
                                        vdm.prodDept.script = response.data.prodDept.script;
                                        vdm.prodDept.intro = response.data.prodDept.intro;
                                        vdm.prodDept.conclu = response.data.prodDept.conclu;
                                        vdm.prodDept.vidDev = response.data.prodDept.vidDev;
                                        vdm.prodDept.status = response.data.prodDept.status;

                                        vdm.writable = false;
                                    }, function(error){
                                        $("body").css("cursor", "default");
                                        $scope.disableProdSave = false;
                                        console.log(error)
                                    })
                                }, function(){
                                    $("body").css("cursor", "default");
                                    $scope.disableProdSave = false;
                                })
                            }else{
                                $("body").css("cursor", "progress");
                                dawProcessManagerService.updateVdm(vdm, function (response){
                                    swal({
                                        title: "Exitoso",
                                        text: "Se ha actualizado el MDT del video " + response.data.videoId,
                                        type: 'success',
                                        confirmButtonText: "OK",
                                        confirmButtonColor: "lightskyblue"
                                    });
                                    $("body").css("cursor", "default");
                                    $scope.disableProdSave = false;

                                    vdm.prodDept.script = response.data.prodDept.script;
                                    vdm.prodDept.intro = response.data.prodDept.intro;
                                    vdm.prodDept.conclu = response.data.prodDept.conclu;
                                    vdm.prodDept.vidDev = response.data.prodDept.vidDev;
                                    vdm.prodDept.status = response.data.prodDept.status;

                                    vdm.writable = false;
                                }, function(error){
                                    $("body").css("cursor", "default");
                                    $scope.disableProdSave = false;

                                    console.log(error)
                                })
                            }
                        }
                    };
                }else{
                    if (incomplete){
                        $("body").css("cursor", "default");
                        swal({
                            title: 'Justificar creacion',
                            input: 'textarea',
                            text: mesage,
                            type: 'question',
                            showCancelButton: true
                        }).then(function(text){
                            $("body").css("cursor", "progress");
                            vdm.prodDept.justification = text;
                            dawProcessManagerService.updateVdm(vdm, function (response){
                                swal({
                                    title: "Exitoso",
                                    text: "Se ha actualizado el MDT del video " + response.data.videoId,
                                    type: 'success',
                                    confirmButtonText: "OK",
                                    confirmButtonColor: "lightskyblue"
                                });
                                $("body").css("cursor", "default");
                                $scope.disableProdSave = false;

                                vdm.prodDept.script = response.data.prodDept.script;
                                vdm.prodDept.intro = response.data.prodDept.intro;
                                vdm.prodDept.conclu = response.data.prodDept.conclu;
                                vdm.prodDept.vidDev = response.data.prodDept.vidDev;
                                vdm.prodDept.status = response.data.prodDept.status;
                                vdm.writable = false;
                            }, function(error){
                                $("body").css("cursor", "default");
                                $scope.disableProdSave = false;
                                console.log(error)
                            })
                        }, function(){
                            $("body").css("cursor", "default");
                            $scope.disableProdSave = false;
                        })
                    }else{
                        $("body").css("cursor", "progress");
                        dawProcessManagerService.updateVdm(vdm, function (response){
                            swal({
                                title: "Exitoso",
                                text: "Se ha actualizado el MDT del video " + response.data.videoId,
                                type: 'success',
                                confirmButtonText: "OK",
                                confirmButtonColor: "lightskyblue"
                            });
                            $("body").css("cursor", "default");
                            $scope.disableProdSave = false;

                            vdm.prodDept.script = response.data.prodDept.script;
                            vdm.prodDept.intro = response.data.prodDept.intro;
                            vdm.prodDept.conclu = response.data.prodDept.conclu;
                            vdm.prodDept.vidDev = response.data.prodDept.vidDev;
                            vdm.prodDept.status = response.data.prodDept.status;
                            vdm.writable = false;
                        }, function(error){
                            $("body").css("cursor", "default");
                            $scope.disableProdSave = false;
                            console.log(error)
                        })
                    }
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
