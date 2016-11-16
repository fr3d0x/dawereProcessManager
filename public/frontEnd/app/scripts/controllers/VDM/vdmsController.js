/**
 * Created by fr3d0 on 28/07/16.
 */
'use strict';
app.controller("vdmsController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', 'NgTableParams', '$filter','$rootScope',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, NgTableParams, $filter, $rootScope){
        $scope.assignmentStatus = null;
        var getEditorsJson = function (employees) {
            var editors = $filter('roles')(employees, ['editor']);
            var editorsJson = {};
            for (var i = 0; i<editors.length; i++){
                var name = editors[i].name;
                editorsJson[editors[i].id] = name;
            }
            return editorsJson
        };
        var getDepartmentsToReturn = function (vdm) {
            var departments = {};
            if($rootScope.currentRole != 'productManager'){
                if(vdm.prodDept != null){
                    if(vdm.prodDept.id != null && vdm.prodDept.status != 'no asignado'){
                        departments['production'] = 'Produccion';
                    }
                    if(vdm.prodDept.assignment != null){
                        departments['edition'] = 'Edicion'
                    }
                }
                if(vdm.designDept != null ){
                    if(vdm.designDept.assignment != null && vdm.designDept.status != 'no asignado'){
                        if(vdm.designDept.assignment.status != 'no asignado' != null){
                            departments['design'] = 'Diseño'
                        }
                    }
                }
                if(vdm.postProdDept != null){
                    if(vdm.postProdDept.assignment != null && vdm.postProdDept.status != 'no asignado'){
                        if(vdm.postProdDept.assignment.status != 'no asignado'){
                            departments['postProduction'] = 'Post-Produccion'
                        }
                    }
                }
            }else{
                if(vdm.productManagement != null){
                    if(vdm.productManagement.productionStatus != null && vdm.productManagement.productionStatus == 'por aprobar'){
                        departments['production'] = 'Produccion';
                    }
                    if(vdm.productManagement.editionStatus != null && vdm.productManagement.editionStatus == 'por aprobar'){
                        departments['edition'] = 'Edicion'
                    }
                    if(vdm.productManagement.designStatus != null && vdm.productManagement.designStatus == 'por aprobar'){
                        departments['design'] = 'Diseño'
                    }
                    if(vdm.productManagement.postProductionStatus != null && vdm.productManagement.postProductionStatus == 'por aprobar'){
                        departments['postProduction'] = 'Post-Produccion'
                    }
                }
            }

            return departments
        };
        var getVdms = function(){
            dawProcessManagerService.getVdmsBySubject($stateParams.id, function (response)  {
                var tableData = [];
                $scope.emptyResponse = false;
                $scope.subject = response.subject;
                if (response.data != null){
                    $scope.employees = response.employees;
                    switch (localStorageService.get('currentRole')){
                        case 'contentLeader':
                            tableData = response.data;
                            break;
                        case 'contentAnalist':
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
                        case 'designer':
                            var user = JSON.parse(atob(localStorageService.get('encodedToken').split(".")[1]));
                            tableData = $filter('vdmsByUser')(response.design, user, localStorageService.get('currentRole'));
                            break;
                        case 'post-producer':
                            var user = JSON.parse(atob(localStorageService.get('encodedToken').split(".")[1]));
                            tableData = $filter('vdmsByUser')(response.postProduction, user, localStorageService.get('currentRole'));
                            break;
                        case 'postProLeader':
                            tableData = response.postProduction;
                            break;
                        case 'qa':
                            tableData = response.qaDpt;
                            break;
                        case 'qaAnalist':
                            var user = JSON.parse(atob(localStorageService.get('encodedToken').split(".")[1]));
                            tableData = response.qaDpt;
                            break;
                    }
                    $scope.tableParams = new NgTableParams({
                        sorting: {
                            topicNumber: 'asc'
                        }
                    },{
                        filterOptions: { filterLayout: "horizontal" },
                        dataset: tableData,
                        groupBy: 'cpId'
                    });
                }else{
                    $scope.emptyResponse = true;
                }
            }, function(error) {
                alert(error);
            })
        };

        $scope.states = [{statusIng: 'not received', statusSpa: 'no recibido'}, {statusIng: 'received', statusSpa: 'recibido'}, {statusIng: 'processed', statusSpa: 'procesado'}];
        $scope.editorStates = [{statusIng: 'edited', statusSpa: 'editado'}];
        $scope.designerStates = [{statusIng: 'designed', statusSpa: 'diseñado'}];
        $scope.postProducerStates = [{statusIng: 'post-produced', statusSpa: 'terminado'}];
        $scope.vdmTypes = [{typeIng: 'exercises', typeSpa: 'ejercicios'}, {typeIng: 'theoretical', typeSpa: 'teorico'}, {typeIng: 'descriptive', typeSpa: 'narrativo'}, {typeIng: 'experimental', typeSpa: 'experimental'}];


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
                            }).then(function(){
                                location.reload();
                            }, function(){});
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

        $scope.saveVdmProd = function(vdm, file){
            $scope.disableSave = true;
            $("body").css("cursor", "progress !important");
            if (vdm != null){
                vdm.role = localStorageService.get('currentRole');
                var mesage = '';
                var incomplete = false;
                var scriptPresent = false;
                var assigned = false;
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
                if(vdm.prodDept.script != null && vdm.prodDept.script != ''){
                    scriptPresent = true;
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
                            $scope.disableSave = false;
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
                                $scope.disableSave = false;
                                $("body").css("cursor", "default");
                                swal({
                                    title: 'Justificar',
                                    text: mesage,
                                    input: 'textarea',
                                    type: 'question',
                                    showCancelButton: true
                                }).then(function(text){
                                    $scope.disableSave = true;
                                    $("body").css("cursor", "progress");
                                    vdm.prodDept.justification = text;
                                    dawProcessManagerService.updateVdm(vdm, function (response){
                                        $("body").css("cursor", "default");
                                        $scope.disableSave = false;

                                        if(response.data.prodDept != null){
                                            vdm.script = response.data.prodDept.script;
                                            vdm.intro = response.data.prodDept.intro;
                                            vdm.conclu = response.data.prodDept.conclu;
                                            vdm.vidDev = response.data.prodDept.vidDev;
                                            vdm.prodDept = response.data.prodDept;
                                            if(response.data.prodDept.assignment != null){
                                                if(response.data.prodDept.assignment.user_id != null){
                                                    assigned = true;
                                                }
                                            }
                                            if(response.data.prodDept.status == 'grabado' && !assigned){
                                                swal({
                                                    title: 'Seleccione Editor para asignar el video',
                                                    input: 'select',
                                                    inputOptions: getEditorsJson($scope.employees),
                                                    inputPlaceholder: 'Seleccione',
                                                    showCancelButton: true,
                                                    inputValidator: function(value) {
                                                        return new Promise(function(resolve, reject) {
                                                            if (value != '') {
                                                                resolve();
                                                            } else {
                                                                reject('Seleccione un Editor o presione cancelar)');
                                                            }
                                                        });
                                                    }
                                                }).then(function(result){
                                                    if(result != null){
                                                        vdm.asignedId = result;
                                                        $("body").css("cursor", "progress");
                                                        $scope.disableSave = true;
                                                        dawProcessManagerService.updateVdm(vdm, function (response){
                                                            $("body").css("cursor", "default");
                                                            $scope.disableSave = false;
                                                            swal({
                                                                title: "Exitoso",
                                                                text: "Se ha actualizado el MDT del video " + response.data.videoId,
                                                                type: 'success',
                                                                confirmButtonText: "OK",
                                                                confirmButtonColor: "lightskyblue"
                                                            });
                                                            if(response.data.prodDept != null){
                                                                vdm.script = response.data.prodDept.script;
                                                                vdm.intro = response.data.prodDept.intro;
                                                                vdm.conclu = response.data.prodDept.conclu;
                                                                vdm.vidDev = response.data.prodDept.vidDev;
                                                                vdm.prodDept = response.data.prodDept;
                                                            }

                                                        }, function(error){
                                                            console.log(error);
                                                        });
                                                    }
                                                }, function(){
                                                    $("body").css("cursor", "default");
                                                    $scope.disableSave = false;
                                                })
                                            }else{
                                                swal({
                                                    title: "Exitoso",
                                                    text: "Se ha actualizado el MDT del video " + response.data.videoId,
                                                    type: 'success',
                                                    confirmButtonText: "OK",
                                                    confirmButtonColor: "lightskyblue"
                                                });
                                                $("body").css("cursor", "default");
                                                $scope.disableSave = false;
                                                if(response.data.prodDept != null){
                                                    vdm.script = response.data.prodDept.script;
                                                    vdm.intro = response.data.prodDept.intro;
                                                    vdm.conclu = response.data.prodDept.conclu;
                                                    vdm.vidDev = response.data.prodDept.vidDev;
                                                    vdm.prodDept = response.data.prodDept;
                                                }
                                            }
                                        }
                                        vdm.writable = false;
                                    }, function(error){
                                        $("body").css("cursor", "default");
                                        $scope.disableSave = false;
                                        console.log(error)
                                    })
                                }, function(){
                                    $("body").css("cursor", "default");
                                    $scope.disableSave = false;
                                })
                            }else{
                                $("body").css("cursor", "progress");
                                dawProcessManagerService.updateVdm(vdm, function (response){
                                    $("body").css("cursor", "default");
                                    $scope.disableSave = false;
                                    if(response.data.prodDept != null) {
                                        vdm.script = response.data.prodDept.script;
                                        vdm.intro = response.data.prodDept.intro;
                                        vdm.conclu = response.data.prodDept.conclu;
                                        vdm.vidDev = response.data.prodDept.vidDev;
                                        vdm.prodDept = response.data.prodDept;
                                        if(response.data.prodDept.assignment != null){
                                            if(response.data.prodDept.assignment.user_id != null){
                                                assigned = true;
                                            }
                                        }
                                        if(response.data.prodDept.status == 'grabado' && !assigned){
                                            swal({
                                                title: 'Seleccione Editor para asignar el video',
                                                input: 'select',
                                                inputOptions: getEditorsJson($scope.employees),
                                                inputPlaceholder: 'Seleccione',
                                                showCancelButton: true,
                                                inputValidator: function(value) {
                                                    return new Promise(function(resolve, reject) {
                                                        if (value != '') {
                                                            resolve();
                                                        } else {
                                                            reject('Seleccione un Editor o presione cancelar)');
                                                        }
                                                    });
                                                }
                                            }).then(function(result){
                                                if(result != null){
                                                    vdm.asignedId = result;
                                                    $("body").css("cursor", "progress");
                                                    $scope.disableSave = true;
                                                    dawProcessManagerService.updateVdm(vdm, function (response){
                                                        $("body").css("cursor", "default");
                                                        $scope.disableSave = false;
                                                        swal({
                                                            title: "Exitoso",
                                                            text: "Se ha actualizado el MDT del video " + response.data.videoId,
                                                            type: 'success',
                                                            confirmButtonText: "OK",
                                                            confirmButtonColor: "lightskyblue"
                                                        });
                                                        if(response.data.prodDept != null){
                                                            vdm.script = response.data.prodDept.script;
                                                            vdm.intro = response.data.prodDept.intro;
                                                            vdm.conclu = response.data.prodDept.conclu;
                                                            vdm.vidDev = response.data.prodDept.vidDev;
                                                            vdm.prodDept = response.data.prodDept;
                                                        }

                                                    }, function(error){
                                                        console.log(error);
                                                    });
                                                }
                                            }, function(){
                                                $("body").css("cursor", "default");
                                                $scope.disableSave = false;
                                            })
                                        }else{
                                            swal({
                                                title: "Exitoso",
                                                text: "Se ha actualizado el MDT del video " + response.data.videoId,
                                                type: 'success',
                                                confirmButtonText: "OK",
                                                confirmButtonColor: "lightskyblue"
                                            });
                                            $("body").css("cursor", "default");
                                            $scope.disableSave = false;
                                            if(response.data.prodDept != null){
                                                vdm.script = response.data.prodDept.script;
                                                vdm.intro = response.data.prodDept.intro;
                                                vdm.conclu = response.data.prodDept.conclu;
                                                vdm.vidDev = response.data.prodDept.vidDev;
                                                vdm.prodDept = response.data.prodDept;
                                            }
                                        }
                                    }
                                    vdm.writable = false;
                                }, function(error){
                                    $("body").css("cursor", "default");
                                    $scope.disableSave = false;

                                    console.log(error)
                                })
                            }
                        }
                    };
                }else{
                    if(!scriptPresent){
                        swal({
                            title: 'Aviso',
                            text: 'Para empezar con las grabaciones debe agregar un guion',
                            type: 'warning',
                            showCancelButton: false,
                            confirmButtonText: "OK",
                            confirmButtonColor: "lightcoral"
                        });
                        $("body").css("cursor", "default");
                        $scope.disableSave = false;
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
                                    $("body").css("cursor", "default");
                                    $scope.disableSave = false;
                                    if(response.data.prodDept != null) {
                                        vdm.script = response.data.prodDept.script;
                                        vdm.intro = response.data.prodDept.intro;
                                        vdm.conclu = response.data.prodDept.conclu;
                                        vdm.vidDev = response.data.prodDept.vidDev;
                                        vdm.prodDept = response.data.prodDept;
                                        if(response.data.prodDept.assignment != null){
                                            if(response.data.prodDept.assignment.user_id != null){
                                                assigned = true;
                                            }
                                        }
                                        if(response.data.prodDept.status == 'grabado' && !assigned){
                                            swal({
                                                title: 'Seleccione Editor para asignar el video',
                                                input: 'select',
                                                inputOptions: getEditorsJson($scope.employees),
                                                inputPlaceholder: 'Seleccione',
                                                showCancelButton: true,
                                                inputValidator: function(value) {
                                                    return new Promise(function(resolve, reject) {
                                                        if (value != '') {
                                                            resolve();
                                                        } else {
                                                            reject('Seleccione un Editor o presione cancelar)');
                                                        }
                                                    });
                                                }
                                            }).then(function(result){
                                                if(result != null){
                                                    vdm.asignedId = result;
                                                    $("body").css("cursor", "progress");
                                                    $scope.disableSave = true;
                                                    dawProcessManagerService.updateVdm(vdm, function (response){
                                                        $("body").css("cursor", "default");
                                                        $scope.disableSave = false;
                                                        swal({
                                                            title: "Exitoso",
                                                            text: "Se ha actualizado el MDT del video " + response.data.videoId,
                                                            type: 'success',
                                                            confirmButtonText: "OK",
                                                            confirmButtonColor: "lightskyblue"
                                                        });
                                                        if(response.data.prodDept != null){
                                                            vdm.script = response.data.prodDept.script;
                                                            vdm.intro = response.data.prodDept.intro;
                                                            vdm.conclu = response.data.prodDept.conclu;
                                                            vdm.vidDev = response.data.prodDept.vidDev;
                                                            vdm.prodDept = response.data.prodDept;
                                                        }

                                                    }, function(error){
                                                        console.log(error);
                                                    });
                                                }
                                            }, function(){
                                                $("body").css("cursor", "default");
                                                $scope.disableSave = false;
                                            })
                                        }else{
                                            swal({
                                                title: "Exitoso",
                                                text: "Se ha actualizado el MDT del video " + response.data.videoId,
                                                type: 'success',
                                                confirmButtonText: "OK",
                                                confirmButtonColor: "lightskyblue"
                                            });
                                            $("body").css("cursor", "default");
                                            $scope.disableSave = false;
                                            if(response.data.prodDept != null){
                                                vdm.script = response.data.prodDept.script;
                                                vdm.intro = response.data.prodDept.intro;
                                                vdm.conclu = response.data.prodDept.conclu;
                                                vdm.vidDev = response.data.prodDept.vidDev;
                                                vdm.prodDept = response.data.prodDept;
                                            }
                                        }
                                    }

                                    vdm.writable = false;
                                }, function(error){
                                    $("body").css("cursor", "default");
                                    $scope.disableSave = false;
                                    console.log(error)
                                })
                            }, function(){
                                $("body").css("cursor", "default");
                                $scope.disableSave = false;
                            })
                        }else{
                            $("body").css("cursor", "progress");
                            dawProcessManagerService.updateVdm(vdm, function (response){
                                $("body").css("cursor", "default");
                                $scope.disableSave = false;
                                if(response.data.prodDept != null) {
                                    vdm.script = response.data.prodDept.script;
                                    vdm.intro = response.data.prodDept.intro;
                                    vdm.conclu = response.data.prodDept.conclu;
                                    vdm.vidDev = response.data.prodDept.vidDev;
                                    vdm.prodDept = response.data.prodDept;
                                    if(response.data.prodDept.assignment != null){
                                        if(response.data.prodDept.assignment.user_id != null){
                                            assigned = true;
                                        }
                                    }
                                    if(response.data.prodDept.status == 'grabado' && !assigned){
                                        swal({
                                            title: 'Seleccione Editor para asignar el video',
                                            input: 'select',
                                            inputOptions: getEditorsJson($scope.employees),
                                            inputPlaceholder: 'Seleccione',
                                            showCancelButton: true,
                                            inputValidator: function(value) {
                                                return new Promise(function(resolve, reject) {
                                                    if (value != '') {
                                                        resolve();
                                                    } else {
                                                        reject('Seleccione un Editor o presione cancelar)');
                                                    }
                                                });
                                            }
                                        }).then(function(result){
                                            if(result != null){
                                                vdm.asignedId = result;
                                                $("body").css("cursor", "progress");
                                                $scope.disableSave = true;
                                                dawProcessManagerService.updateVdm(vdm, function (response){
                                                    $("body").css("cursor", "default");
                                                    $scope.disableSave = false;
                                                    swal({
                                                        title: "Exitoso",
                                                        text: "Se ha actualizado el MDT del video " + response.data.videoId,
                                                        type: 'success',
                                                        confirmButtonText: "OK",
                                                        confirmButtonColor: "lightskyblue"
                                                    });
                                                    if(response.data.prodDept != null){
                                                        vdm.script = response.data.prodDept.script;
                                                        vdm.intro = response.data.prodDept.intro;
                                                        vdm.conclu = response.data.prodDept.conclu;
                                                        vdm.vidDev = response.data.prodDept.vidDev;
                                                        vdm.prodDept = response.data.prodDept;
                                                    }

                                                }, function(error){
                                                    console.log(error);
                                                });
                                            }
                                        }, function(){
                                            $("body").css("cursor", "default");
                                            $scope.disableSave = false;
                                        })
                                    }else{
                                        swal({
                                            title: "Exitoso",
                                            text: "Se ha actualizado el MDT del video " + response.data.videoId,
                                            type: 'success',
                                            confirmButtonText: "OK",
                                            confirmButtonColor: "lightskyblue"
                                        });
                                        $("body").css("cursor", "default");
                                        $scope.disableSave = false;
                                        if(response.data.prodDept != null){
                                            vdm.script = response.data.prodDept.script;
                                            vdm.intro = response.data.prodDept.intro;
                                            vdm.conclu = response.data.prodDept.conclu;
                                            vdm.vidDev = response.data.prodDept.vidDev;
                                            vdm.prodDept = response.data.prodDept;
                                        }
                                    }
                                }
                                vdm.writable = false;
                            }, function(error){
                                $("body").css("cursor", "default");
                                $scope.disableSave = false;
                                console.log(error)
                            })
                        }
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
                    vdm.role = localStorageService.get('currentRole');
                    dawProcessManagerService.updateVdm(vdm, function (response){
                        swal({
                            title: "Exitoso",
                            text: "Se ha actualizado el MDT del video " + response.data.videoId,
                            type: 'success',
                            confirmButtonText: "OK",
                            confirmButtonColor: "lightskyblue"
                        });
                        $("body").css("cursor", "default");
                        $scope.disableSave = false;
                        vdm.writable = false;
                        vdm.prodDept.assignment.status = response.data.prodDept.assignment.status;
                        vdm.prodDept.assignment.comments = response.data.prodDept.assignment.comments;

                    }, function(error){
                        console.log(error);
                        $("body").css("cursor", "default");
                        $scope.disableSave = false;
                    })
                }
            }
        };

        $scope.saveVdmDesigner = function(vdm){
            $scope.disableSave = true;
            $("body").css("cursor", "progress");
            if (vdm != null){
                if(vdm.id != null){
                    if (vdm.assignmentDesignStatus != null){
                        vdm.designDept.assignment.status = vdm.assignmentDesignStatus;
                    }
                    vdm.role = localStorageService.get('currentRole');
                    dawProcessManagerService.updateVdm(vdm, function (response){
                        swal({
                            title: "Exitoso",
                            text: "Se ha actualizado el MDT del video " + response.data.videoId,
                            type: 'success',
                            confirmButtonText: "OK",
                            confirmButtonColor: "lightskyblue"
                        });
                        $("body").css("cursor", "default");
                        $scope.disableSave = false;
                        vdm.writable = false;
                        if(response.data.designDept.assignment != null){
                            vdm.designDept.assignment = response.data.designDept.assignment
                        }

                    }, function(error){
                        console.log(error);
                        $("body").css("cursor", "default");
                        $scope.disableSave = false;
                    })
                }
            }
        };

        $scope.saveVdmPostProducer = function(vdm) {
            $scope.disableSave = true;
            $("body").css("cursor", "progress");
            if (vdm != null){
                if(vdm.id != null){
                    if (vdm.assignmentPostPStatus != null){
                        vdm.postProdDept.assignment.status = vdm.assignmentPostPStatus;
                    }
                    vdm.role = localStorageService.get('currentRole');
                    dawProcessManagerService.updateVdm(vdm, function (response){
                        swal({
                            title: "Exitoso",
                            text: "Se ha actualizado el MDT del video " + response.data.videoId,
                            type: 'success',
                            confirmButtonText: "OK",
                            confirmButtonColor: "lightskyblue"
                        });
                        $("body").css("cursor", "default");
                        $scope.disableSave = false;
                        vdm.writable = false;
                        if(response.data.designDept.assignment != null){
                            vdm.designDept.assignment = response.data.designDept.assignment
                        }

                    }, function(error){
                        console.log(error);
                        $("body").css("cursor", "default");
                        $scope.disableSave = false;
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
                        $scope.disableSave = false;
                        if (vdm.prodDept != null){
                            if (vdm.prodDept.assignment != null){
                                if(response.data.editionStatus != null){
                                    vdm.prodDept.assignment.status = response.data.editionStatus
                                }
                            }
                            if(response.data.prodDeptStatus != null){
                                vdm.prodDept.status = response.data.prodDeptStatus;
                            }
                        }
                        if (vdm.designDept != null){
                            if (vdm.designDept.assignment != null){
                                if(response.data.designAsignmentStatus != null){
                                    vdm.designDept.assignment.status = response.data.designAsignmentStatus
                                }
                            }
                            if(response.data.designStatus != null){
                                vdm.designDept.status = response.data.designStatus;
                            }
                        }
                        if (vdm.postProdDept != null){
                            if (vdm.postProdDept.assignment != null){
                                if(response.data.postProdAssignmentStatus != null){
                                    vdm.postProdDept.assignment.status = response.data.postProdAssignmentStatus
                                }
                            }
                            if(response.data.postProdStatus != null){
                                vdm.postProdDept.status = response.data.postProdStatus;
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
                vdm.role = localStorageService.get('currentRole');
                if (vdm.id != null) {
                    swal({
                        title: 'Seleccione departamento para devolver el video',
                        input: 'select',
                        inputOptions: getDepartmentsToReturn(vdm),
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
                                                $scope.disableSave = false;
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
                                                if(response.data.designDept != null){
                                                    vdm.designDept = response.data.designDept;
                                                }
                                                if(response.data.postProdDept != null){
                                                    vdm.postProdDept = response.data.postProdDept;
                                                }
                                            }, function(error){
                                                $("body").css("cursor", "default");
                                                $scope.disableSave = false;
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
                                            if(response.data.designDept != null){
                                                vdm.designDept = response.data.designDept;
                                            }
                                            if(response.data.postProdDept != null){
                                                vdm.postProdDept = response.data.postProdDept;
                                            }
                                            $("body").css("cursor", "default");
                                            $scope.disableSave = false;
                                        }, function(error){
                                            $("body").css("cursor", "default");
                                            $scope.disableSave = false;
                                            console.log(error)
                                        });
                                    }, function(){
                                        $("body").css("cursor", "default");
                                        $scope.disableSave = false;
                                    });
                                    break;
                                case 'design':
                                    swal({
                                        title: 'Justificar rechazo',
                                        input: 'textarea',
                                        type: 'question',
                                        showCancelButton: true
                                    }).then(function(text){
                                        $("body").css("cursor", "progress");
                                        var request = {};
                                        request.rejection = 'design';
                                        request.justification = text;
                                        request.vdmId = vdm.id;
                                        request.rejectedFrom = department;
                                        request.role = localStorageService.get('currentRole');
                                        dawProcessManagerService.rejectVdm(request, function (response) {
                                            swal({
                                                title: "Exitoso",
                                                text: "Se ha rechazado el MDT del video " + vdm.videoId+" y ha sido devuelto a diseño",
                                                type: 'success',
                                                confirmButtonText: "OK",
                                                confirmButtonColor: "lightskyblue"
                                            });
                                            
                                            if(response.data.designDept != null){
                                                vdm.designDept = response.data.designDept;
                                            }
                                            if(response.data.postProdDept != null){
                                                vdm.postProdDept = response.data.postProdDept;
                                            }
                                            if(vdm.productManagement != null){
                                                if (response.data.productManagement != null){
                                                    vdm.productManagement = response.data.productManagement;
                                                }
                                            }
                                            $("body").css("cursor", "default");
                                            $scope.disableSave = false;
                                        }, function(error){
                                            $("body").css("cursor", "default");
                                            $scope.disableSave = false;
                                            console.log(error)
                                        });
                                    }, function(){
                                        $("body").css("cursor", "default");
                                        $scope.disableSave = false;
                                    });
                                    break;
                                case 'postProduction':
                                    swal({
                                        title: 'Justificar rechazo',
                                        input: 'textarea',
                                        type: 'question',
                                        showCancelButton: true
                                    }).then(function(text){
                                        $("body").css("cursor", "progress");
                                        var request = {};
                                        request.rejection = 'postProduction';
                                        request.justification = text;
                                        request.vdmId = vdm.id;
                                        request.rejectedFrom = department;
                                        request.role = localStorageService.get('currentRole');
                                        dawProcessManagerService.rejectVdm(request, function (response) {
                                            swal({
                                                title: "Exitoso",
                                                text: "Se ha rechazado el MDT del video " + vdm.videoId+" y ha sido devuelto a post-produccion",
                                                type: 'success',
                                                confirmButtonText: "OK",
                                                confirmButtonColor: "lightskyblue"
                                            });

                                            if(response.data.postProdDept != null){
                                                vdm.postProdDept = response.data.postProdDept;
                                            }
                                            if(vdm.productManagement != null){
                                                if (response.data.productManagement != null){
                                                    vdm.productManagement = response.data.productManagement;
                                                }
                                            }
                                            $("body").css("cursor", "default");
                                            $scope.disableSave = false;
                                        }, function(error){
                                            $("body").css("cursor", "default");
                                            $scope.disableSave = false;
                                            console.log(error)
                                        });
                                    }, function(){
                                        $("body").css("cursor", "default");
                                        $scope.disableSave = false;
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
