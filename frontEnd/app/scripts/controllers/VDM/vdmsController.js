/**
 * Created by fr3d0 on 28/07/16.
 */
'use strict';
app.controller("vdmsController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', 'NgTableParams', '$filter',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, NgTableParams, $filter){
        $scope.assignmentStatus = null;
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
                    case 'editor':
                        var user = JSON.parse(atob(localStorageService.get('encodedToken').split(".")[1]));
                        tableData = $filter('vdmsByUser')(response.production, user, localStorageService.get('currentRole'));
                        break;
                    case 'productManager':
                        tableData = response.productManagement;
                        break;
                    case 'designLeader':
                        tableData = response.design;
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
        $scope.editorStates = [{statusIng: 'edited', statusSpa: 'editado'}];

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
            var request = angular.copy(vdm);
            $("body").css("cursor", "progress");
            if (vdm != null){
                if(vdm.id != null){
                    if (request.prodDept != null){
                        delete request.prodDept
                    }
                    dawProcessManagerService.updateVdm(request, function (response){
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
                    if (vdm.intro == vdm.prodDept.conclu != true || vdm.prodDept.vidDev != true){
                        mesage = "Grabacion incompleta solo introduccion";
                        incomplete = true
                    }
                }
                if (vdm.intro == vdm.prodDept.intro && vdm.conclu != vdm.prodDept.conclu && vdm.vidDev == vdm.prodDept.vidDev){
                    if (vdm.intro == vdm.prodDept.intro != true || vdm.prodDept.vidDev != true){
                        mesage = "Grabacion incompleta solo conclusion";
                        incomplete = true
                    }
                }
                if (vdm.intro == vdm.prodDept.intro && vdm.conclu == vdm.prodDept.conclu && vdm.vidDev != vdm.prodDept.vidDev){
                    if (vdm.intro == vdm.prodDept.intro != true || vdm.prodDept.conclu != true) {
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
                                        vdm.script = response.data.prodDept.script;
                                        vdm.prodDept.intro = response.data.prodDept.intro;
                                        vdm.intro = vdm.prodDept.intro;
                                        vdm.prodDept.conclu = response.data.prodDept.conclu;
                                        vdm.conclu = vdm.prodDept.conclu;
                                        vdm.prodDept.vidDev = response.data.prodDept.vidDev;
                                        vdm.vidDev = vdm.prodDept.vidDev;
                                        vdm.prodDept.status = response.data.prodDept.status;
                                        if(response.data.prodDept.assignment != null){
                                            vdm.prodDept.assignment.assignedName = response.data.prodDept.assignment.assignedName;
                                            vdm.prodDept.assignment.id = response.data.prodDept.assignment.id;
                                            vdm.prodDept.assignment.status = response.data.prodDept.assignment.status;
                                        }

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

                                    vdm.script = response.data.prodDept.script;
                                    vdm.script = response.data.prodDept.script;
                                    vdm.prodDept.intro = response.data.prodDept.intro;
                                    vdm.intro = vdm.prodDept.intro;
                                    vdm.prodDept.conclu = response.data.prodDept.conclu;
                                    vdm.conclu = vdm.prodDept.conclu;
                                    vdm.prodDept.vidDev = response.data.prodDept.vidDev;
                                    vdm.vidDev = vdm.prodDept.vidDev;
                                    vdm.prodDept.status = response.data.prodDept.status;
                                    if(response.data.prodDept.assignment != null){
                                        vdm.prodDept.assignment.assignedName = response.data.prodDept.assignment.assignedName;
                                        vdm.prodDept.assignment.id = response.data.prodDept.assignment.id;
                                        vdm.prodDept.assignment.status = response.data.prodDept.assignment.status;
                                    }

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

                                vdm.script = response.data.prodDept.script;
                                vdm.prodDept.intro = response.data.prodDept.intro;
                                vdm.intro = vdm.prodDept.intro;
                                vdm.prodDept.conclu = response.data.prodDept.conclu;
                                vdm.conclu = vdm.prodDept.conclu;
                                vdm.prodDept.vidDev = response.data.prodDept.vidDev;
                                vdm.vidDev = vdm.prodDept.vidDev;
                                vdm.prodDept.status = response.data.prodDept.status;
                                if(response.data.prodDept.assignment != null){
                                    vdm.prodDept.assignment.assignedName = response.data.prodDept.assignment.assignedName;
                                    vdm.prodDept.assignment.id = response.data.prodDept.assignment.id;
                                    vdm.prodDept.assignment.status = response.data.prodDept.assignment.status;
                                }
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

                            vdm.script = response.data.prodDept.script;
                            vdm.prodDept.intro = response.data.prodDept.intro;
                            vdm.intro = vdm.prodDept.intro;
                            vdm.prodDept.conclu = response.data.prodDept.conclu;
                            vdm.conclu = vdm.prodDept.conclu;
                            vdm.prodDept.vidDev = response.data.prodDept.vidDev;
                            vdm.vidDev = vdm.prodDept.vidDev;
                            vdm.prodDept.status = response.data.prodDept.status;
                            if(response.data.prodDept.assignment != null) {
                                vdm.prodDept.assignment = response.data.prodDept.assignment
                            }

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

        $scope.saveVdmEditor = function(vdm){
            $scope.disableSave = true;
            $("body").css("cursor", "progress");
            if (vdm != null){
                if(vdm.id != null){
                    if (vdm.assignmentStatus != null){
                        vdm.prodDept.assignment.status = vdm.assignmentStatus;
                    }
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
                        vdm.writable = false;
                        vdm.prodDept.assignment.status = response.data.prodDept.assignment.status;
                        vdm.prodDept.assignment.comments = response.data.prodDept.assignment.comments;

                    }, function(error){
                        console.log(error);
                        $("body").css("cursor", "default");
                        $scope.disableProdSave = false;
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
        
        $scope.approve = function(vdm, department, approval) {
            $scope.disableSave = true;
            $("body").css("cursor", "progress");
            if (vdm != null) {
                if (vdm.id != null) {
                    var request = {};
                    request.vdmId = vdm.id;
                    request.approvedFrom = department;
                    request.approval = approval;
                    request.role = localStorageService.get('currentRole');
                    dawProcessManagerService.approveVdm(request, function (response) {
                        swal({
                            title: "Exitoso",
                            text: "Se ha aprobado el MDT del video " + vdm.videoId + " para " + approval,
                            type: 'success',
                            confirmButtonText: "OK",
                            confirmButtonColor: "lightskyblue"
                        });
                        $("body").css("cursor", "default");
                        $scope.disableProdSave = false;
                        if (vdm.prodDept != null){
                            if (vdm.prodDept.assignment.status != null){
                                if(response.data.editionStatus != null){
                                    vdm.prodDept.assignment.status = response.data.editionStatus
                                }
                            }
                            if(response.data.prodDeptStatus != null){
                                vdm.prodDept.status = response.data.prodDeptStatus;
                            }
                        }
                        if(vdm.productManagement != null){
                            if (response.data.productManagement != null){
                                vdm.productManagement = response.data.productManagement;
                            }
                        }
                    }, function(error){
                        console.log(error)
                    })
                }
            }
        };

        $scope.reject = function(vdm, department) {
            $scope.disableSave = true;
            if (vdm != null) {
                if (vdm.id != null) {
                    swal({
                        title: 'Seleccione departamento para devolver el video',
                        input: 'select',
                        inputOptions: {
                            'production': 'Produccion',
                            'edition': 'Edicion'
                        },
                        inputPlaceholder: 'Seleccione',
                        showCancelButton: true,
                        inputValidator: function(value) {
                            return new Promise(function(resolve, reject) {
                                if (value != '') {
                                    resolve();
                                } else {
                                    reject('Seleccione un departamento o precione cancelar)');
                                }
                            });
                        }
                    }).then(function(result) {
                        if(result != null){
                            switch  (result){
                                case 'production':
                                    swal({
                                        title: 'seleccione que desea devolver y justifique',
                                        html:
                                        '<input id="swal-intro" type="checkbox" value="true" style="font-weight: bold"> intro ' +
                                        '<input id="swal-vidDev" type="checkbox" value="true" style="font-weight: bold"> desarrollo '+
                                        '<input id="swal-conclu" type="checkbox" value="true" style="font-weight: bold"> conclusion<br>'+
                                        '<textarea id="swal-justification" >',
                                        preConfirm: function() {
                                            return new Promise(function(resolve) {
                                                if (result) {
                                                    resolve([
                                                        $('#swal-intro:checked').val(),
                                                        $('#swal-vidDev:checked').val(),
                                                        $('#swal-conclu:checked').val(),
                                                        $('#swal-justification').val()
                                                    ]);
                                                }
                                            });
                                        }
                                    }).then(function(result) {
                                        $("body").css("cursor", "progress");
                                        if (result != null){
                                            var request = {};
                                            request.rejection = 'production';
                                            request.intro = result[0];
                                            request.vidDev = result[1];
                                            request.conclu = result[2];
                                            request.justification = result[3];
                                            request.rejectedFrom = department;
                                            request.vdmId = vdm.id;
                                            request.role = localStorageService.get('currentRole');
                                            dawProcessManagerService.rejectVdm(request, function (response) {
                                                swal({
                                                    title: "Exitoso",
                                                    text: "Se ha rechazado el MDT del video " + vdm.videoId + " y ha sido devuelto a produccion",
                                                    type: 'success',
                                                    confirmButtonText: "OK",
                                                    confirmButtonColor: "lightskyblue"
                                                });
                                                $("body").css("cursor", "default");
                                                $scope.disableProdSave = false;
                                                vdm.prodDept.intro = response.data.prodDept.intro;
                                                vdm.intro = vdm.prodDept.intro;
                                                vdm.prodDept.conclu = response.data.prodDept.conclu;
                                                vdm.conclu = vdm.prodDept.conclu;
                                                vdm.prodDept.vidDev = response.data.prodDept.vidDev;
                                                vdm.vidDev = vdm.prodDept.vidDev;
                                                vdm.prodDept.status = response.data.prodDept.status;
                                                if(response.data.prodDept.assignment != null){
                                                    vdm.prodDept.assignment.assignedName = response.data.prodDept.assignment.assignedName;
                                                    vdm.prodDept.assignment.id = response.data.prodDept.assignment.id;
                                                    vdm.prodDept.assignment.status = response.data.prodDept.assignment.status;
                                                }
                                                if(vdm.productManagement != null){
                                                    if (response.data.productManagement != null){
                                                        vdm.productManagement = response.data.productManagement;
                                                    }
                                                }
                                            }, function(error){
                                                $("body").css("cursor", "default");
                                                $scope.disableProdSave = false;
                                                console.log(error)
                                            });
                                        }
                                    }, function(){
                                        $scope.disableSave = false;
                                        $("body").css("cursor", "default");
                                    });
                                    break;
                                case 'edition':
                                    swal({
                                        title: 'Justificar rechazo',
                                        input: 'textarea',
                                        type: 'question',
                                        showCancelButton: true
                                    }).then(function(text){
                                        $("body").css("cursor", "progress");
                                        var request = {};
                                        request.rejection = 'edition';
                                        request.justification = text;
                                        request.vdmId = vdm.id;
                                        request.rejectedFrom = department;
                                        request.role = localStorageService.get('currentRole');
                                        dawProcessManagerService.rejectVdm(request, function (response) {
                                            swal({
                                                title: "Exitoso",
                                                text: "Se ha rechazado el MDT del video " + vdm.videoId+" y ha sido devuelto a edicion",
                                                type: 'success',
                                                confirmButtonText: "OK",
                                                confirmButtonColor: "lightskyblue"
                                            });
                                            vdm.prodDept.intro = response.data.prodDept.intro;
                                            vdm.prodDept.conclu = response.data.prodDept.conclu;
                                            vdm.prodDept.vidDev = response.data.prodDept.vidDev;
                                            vdm.prodDept.status = response.data.prodDept.status;
                                            if(response.data.prodDept.assignment != null){
                                                vdm.prodDept.assignment.assignedName = response.data.prodDept.assignment.assignedName;
                                                vdm.prodDept.assignment.id = response.data.prodDept.assignment.id;
                                                vdm.prodDept.assignment.status = response.data.prodDept.assignment.status;
                                            }
                                            if(vdm.productManagement != null){
                                                if (response.data.productManagement != null){
                                                    vdm.productManagement = response.data.productManagement;
                                                }
                                            }
                                            $("body").css("cursor", "default");
                                            $scope.disableProdSave = false;
                                        }, function(error){
                                            $("body").css("cursor", "default");
                                            $scope.disableProdSave = false;
                                            console.log(error)
                                        });
                                    }, function(){
                                        $("body").css("cursor", "default");
                                        $scope.disableProdSave = false;
                                    });
                                    break;
                            }
                        }
                    }, function(){
                        $scope.disableSave = false;
                        $("body").css("cursor", "default");
                    });

                }
            }
        };
        getVdms();
    }]);
