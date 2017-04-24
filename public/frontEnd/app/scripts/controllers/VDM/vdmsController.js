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
            $rootScope.setLoader(true);
            dawProcessManagerService.getVdmsBySubject($stateParams.id, localStorageService.get('currentRole'),function (response)  {
                var tableData = [];
                $scope.emptyResponse = false;
                $scope.subject = response.subject;
                if (response.data != null){
                    $scope.employees = response.employees;
                    switch (localStorageService.get('currentRole')){
                        case 'contentLeader':
                        case 'contentAnalist':
                        case 'production':
                        case 'designLeader':
                        case 'productManager':
                        case 'postProLeader':
                        case 'qa':
                        case 'qaAnalist':
                            tableData = response.data;
                            break;
                        case 'editor':
                        case 'designer':
                        case 'post-producer':
                            tableData = $filter('vdmsByUser')(response.data, JSON.parse(atob(localStorageService.get('encodedToken').split(".")[1])), localStorageService.get('currentRole'));
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
                $rootScope.setLoader(false);
            }, function(error) {
                $rootScope.setLoader(false);
                alert(error);
            })
        };

        $scope.states = [{statusIng: 'not received', statusSpa: 'no recibido'}, {statusIng: 'received', statusSpa: 'recibido'}, {statusIng: 'processed', statusSpa: 'procesado'}];
        $scope.editorStates = [{statusIng: 'edited', statusSpa: 'editado'}];
        $scope.designerStates = [{statusIng: 'designed', statusSpa: 'diseñado'}];
        $scope.postProducerStates = [{statusIng: 'post-produced', statusSpa: 'terminado'}];
        $scope.vdmTypes = [{typeIng: 'wacom', typeSpa: 'wacom'}, {typeIng: 'exercises', typeSpa: 'ejercicios'}, {typeIng: 'descriptive', typeSpa: 'narrativo'}, {typeIng: 'experimental', typeSpa: 'experimental'}, {typeIng: 'mixed', typeSpa: 'mixto'}];


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

        var standarVdmSave = function(vdm){
            dawProcessManagerService.updateVdm(vdm, function (response){
                swal({
                    title: "Exitoso",
                    text: "Se ha actualizado el MDT del video " + response.data.videoId,
                    type: 'success',
                    confirmButtonText: "OK",
                    confirmButtonColor: "lightskyblue"
                });

                if (response.data.designDept != null){
                    vdm.designDept = response.data.designDept;id
                }
                if (response.data.postProdDept != null){
                    vdm.postProdDept = response.data.postProdDept;
                }
                vdm.writable = false;
                vdm.classDoc = response.data.classDoc;
                vdm.class_doc_name = response.data.class_doc_name;
                vdm.teacherFiles = response.data.teacherFiles;
                $scope.disableSave = false;
                $rootScope.setLoader(false);
            }, function(error){
                $scope.disableSave = false;
                $rootScope.setLoader(false);
                console.log(error)
            })
        };

        var justifiedSave = function(vdm){
            $rootScope.setLoader(false);
            swal({
                title: 'Justificar creacion',
                input: 'textarea',
                type: 'question',
                showCancelButton: true
            }).then(function(text) {
                $scope.disableSave = true;
                $rootScope.setLoader(true);
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
                    vdm.classDoc = response.data.classDoc;
                    vdm.class_doc_name = response.data.class_doc_name;
                    vdm.teacherFiles = response.data.teacherFiles;
                    vdm.writable = false;
                    $scope.disableSave = false;
                    $rootScope.setLoader(false);
                }, function(error){
                    $scope.disableSave = false;
                    $rootScope.setLoader(false);
                    console.log(error)
                })
            }, function(){
                $scope.disableSave = false;
                $rootScope.setLoader(false);
            });
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
                        vdm.classDoc = response.data.classDoc;
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
                            vdm.classDoc = response.data.classDoc;
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

        $scope.saveVdmPre = function(vdm){
            $scope.disableSave = true;
            $rootScope.setLoader(true);
            if (vdm != null){
                vdm.role = localStorageService.get('currentRole');
                var valid = true;
                var invalidMsg = '';
                if(vdm.class_doc != undefined && vdm.class_doc != null ) {
                    switch (vdm.class_doc.filetype){
                        case 'application/vnd.ms-powerpoint':
                            vdm.class_doc.base64 = 'data:'+vdm.class_doc.filetype+';base64,'+vdm.class_doc.base64;
                            break;
                        case 'application/vnd.openxmlformats-officedocument.presentationml.presentation':
                            vdm.class_doc.base64 = 'data:'+vdm.class_doc.filetype+';base64,'+vdm.class_doc.base64;
                            break;

                        default:
                            invalidMsg = "Los documentos de clase deben ser presentaciones powerpoint para ser guardados";
                            valid = false;
                            break;
                    }
                }
                if(vdm.teacher_files && vdm.teacher_files.length) {
                    for (var i = 0; i < vdm.teacher_files.length; i++) {
                        switch (vdm.teacher_files[i].filetype){
                            case 'application/pdf':
                                vdm.teacher_files[i].base64 = 'data:'+vdm.teacher_files[i].filetype+';base64,'+vdm.teacher_files[i].base64;
                                break;
                            case 'application/msword':
                                vdm.teacher_files[i].base64 = 'data:'+vdm.teacher_files[i].filetype+';base64,'+vdm.teacher_files[i].base64;
                                break;
                            case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
                                vdm.teacher_files[i].base64 = 'data:'+vdm.teacher_files[i].filetype+';base64,'+vdm.teacher_files[i].base64;
                                break;

                            default:
                                invalidMsg = "Los archivos del profesor deben ser pdf o word para ser guardados";
                                valid = false;
                                break;
                        }
                    }
                }

                if(vdm.status == 'procesado'){
                    if(vdm.classDoc == null || vdm.classDoc == undefined){
                        invalidMsg = "No se puede procesar un video sin primero haber subido el documento de la clase";
                        valid = false;
                    }
                    if(vdm.teacher_files == null || vdm.teacher_files == undefined){
                        invalidMsg = "No se puede procesar un video sin primero haber subido al menos un material de profesor";
                        valid = false;
                    }
                    if(vdm.vdm_type == null || vdm.vdm_type == undefined){
                        invalidMsg = "No se puede procesar un video sin primero indicar su tipo";
                        valid = false;
                    }
                }

                if (valid == false) {
                    $scope.disableSave = false;
                    $rootScope.setLoader(false);
                    swal({
                        title: 'Aviso',
                        text: invalidMsg,
                        type: 'warning',
                        showCancelButton: false,
                        confirmButtonText: "OK",
                        confirmButtonColor: "lightcoral"
                    })
                }else{
                    if(vdm.id != null){
                        standarVdmSave(vdm)
                    }else{
                        justifiedSave(vdm)
                    }
                    
                }
                

            }
        };

        $scope.saveVdmProd = function(vdm){
            $scope.disableSave = true;
            $rootScope.setLoader(true);
            if (vdm != null){
                vdm.role = localStorageService.get('currentRole');
                var mesage = '';
                var incomplete = false;
                var assigned = false;
                var valid = true;
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

                if(vdm.screen_play != null && vdm.screen_play != undefined){
                    switch (vdm.prodDept.screen_play.filetype){
                        case 'application/vnd.ms-powerpoint':
                        case 'application/vnd.openxmlformats-officedocument.presentationml.presentation':
                        case 'application/pdf':
                            vdm.prodDept.screen_play.base64 = 'data:'+vdm.prodDept.screen_play.filetype+';base64,'+vdm.prodDept.screen_play.base64;
                            break;

                        default:
                            mesage = "Los guiones deben ser presentaciones powerpoint o archivos pdf para ser guardados";
                            valid = false;
                            break;
                    }
                }else{
                    if(vdm.prodDept.screen_play == null || vdm.prodDept.screen_play == undefined || vdm.prodDept.screen_play == ''){
                        mesage = "No puede empezar una grabacion sin primero haber guardado un libreto y un guion";
                        valid = false;
                    }
                }

                if(vdm.script != null && vdm.script != undefined){
                    switch (vdm.prodDept.script.filetype){
                        case 'application/vnd.ms-excel':
                        case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
                        case 'application/pdf':
                            vdm.prodDept.script.base64 = 'data:'+vdm.prodDept.script.filetype+';base64,'+vdm.prodDept.script.base64;
                            break;

                        default:
                            mesage = "Los libretos deben ser archivos excel o archivos pdf para ser guardados";
                            valid = false;
                            break;
                    }
                }else{
                    if(vdm.prodDept.script == null || vdm.prodDept.script == undefined || vdm.prodDept.script == ''){
                        mesage = "No puede empezar una grabacion sin primero haber guardado un libreto y un guion";
                        valid = false;
                    }

                }

                if (valid == false){
                    $rootScope.setLoader(false);
                    $scope.disableSave = false;
                    swal({
                        title: 'Aviso',
                        text: mesage,
                        type: 'warning',
                        showCancelButton: false,
                        confirmButtonText: "OK",
                        confirmButtonColor: "lightcoral"
                    })
                }else{
                    if (incomplete){
                        $scope.disableSave = false;
                        $rootScope.setLoader(false);
                        swal({
                            title: 'Justificar',
                            text: mesage,
                            input: 'textarea',
                            type: 'question',
                            showCancelButton: true
                        }).then(function(text){
                            $scope.disableSave = true;
                            $rootScope.setLoader(true);
                            vdm.prodDept.justification = text;
                            dawProcessManagerService.updateVdm(vdm, function (response){
                                $rootScope.setLoader(false);
                                $scope.disableSave = false;

                                if(response.data.prodDept != null){
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
                                                vdm.assignedId = result;
                                                $rootScope.setLoader(true);
                                                $scope.disableSave = true;
                                                dawProcessManagerService.updateVdm(vdm, function (response){
                                                    $rootScope.setLoader(false);
                                                    $scope.disableSave = false;
                                                    swal({
                                                        title: "Exitoso",
                                                        text: "Se ha actualizado el MDT del video " + response.data.videoId,
                                                        type: 'success',
                                                        confirmButtonText: "OK",
                                                        confirmButtonColor: "lightskyblue"
                                                    });
                                                    if(response.data.prodDept != null){
                                                        vdm.intro = response.data.prodDept.intro;
                                                        vdm.conclu = response.data.prodDept.conclu;
                                                        vdm.vidDev = response.data.prodDept.vidDev;
                                                        vdm.prodDept = response.data.prodDept;
                                                    }

                                                }, function(error){
                                                    $rootScope.setLoader(false);
                                                    $scope.disableSave = false;
                                                    console.log(error);
                                                });
                                            }
                                        }, function(){
                                            $rootScope.setLoader(false);
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
                                        $rootScope.setLoader(false);
                                        $scope.disableSave = false;
                                        if(response.data.prodDept != null){
                                            vdm.intro = response.data.prodDept.intro;
                                            vdm.conclu = response.data.prodDept.conclu;
                                            vdm.vidDev = response.data.prodDept.vidDev;
                                            vdm.prodDept = response.data.prodDept;
                                        }
                                    }
                                }
                                vdm.writable = false;
                            }, function(error){
                                $rootScope.setLoader(false);
                                $scope.disableSave = false;
                                console.log(error)
                            })
                        }, function(){
                            $rootScope.setLoader(false);
                            $scope.disableSave = false;
                        })
                    }else{
                        $rootScope.setLoader(true);
                        $scope.disableSave = true;
                        dawProcessManagerService.updateVdm(vdm, function (response){
                            $rootScope.setLoader(false);
                            $scope.disableSave = false;
                            if(response.data.prodDept != null) {
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
                                            vdm.assignedId = result;
                                            $rootScope.setLoader(true);
                                            $scope.disableSave = true;
                                            dawProcessManagerService.updateVdm(vdm, function (response){
                                                $rootScope.setLoader(false);
                                                $scope.disableSave = false;
                                                swal({
                                                    title: "Exitoso",
                                                    text: "Se ha actualizado el MDT del video " + response.data.videoId,
                                                    type: 'success',
                                                    confirmButtonText: "OK",
                                                    confirmButtonColor: "lightskyblue"
                                                });
                                                if(response.data.prodDept != null){
                                                    vdm.intro = response.data.prodDept.intro;
                                                    vdm.conclu = response.data.prodDept.conclu;
                                                    vdm.vidDev = response.data.prodDept.vidDev;
                                                    vdm.prodDept = response.data.prodDept;
                                                }

                                            }, function(error){
                                                $rootScope.setLoader(false);
                                                $scope.disableSave = false;
                                                console.log(error);
                                            });
                                        }
                                    }, function(){
                                        $rootScope.setLoader(false);
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
                                    $rootScope.setLoader(false);
                                    $scope.disableSave = false;
                                    if(response.data.prodDept != null){
                                        vdm.intro = response.data.prodDept.intro;
                                        vdm.conclu = response.data.prodDept.conclu;
                                        vdm.vidDev = response.data.prodDept.vidDev;
                                        vdm.prodDept = response.data.prodDept;
                                    }
                                }
                            }
                            vdm.writable = false;
                        }, function(error){
                            $rootScope.setLoader(false);
                            $scope.disableSave = false;
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
        
        $scope.$watch('localStorageService.get("currentRole")', function (newVal, oldVal) {
            if(newVal !== oldVal){
                getVdms();
            }

        })
    }]);
