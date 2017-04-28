/**
 * Created by fr3d0 on 28/07/16.
 */
'use strict';
app.controller("vdmsController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', 'NgTableParams', '$filter','$rootScope', 'Upload',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, NgTableParams, $filter, $rootScope, Upload){
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
                            tableData = response.data;
                            break;
                        case 'editor':
                        case 'designer':
                        case 'post-producer':
                        case 'qa-analyst':
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

        $scope.saveVdm = function(vdm){
            $scope.disableSave = true;
            $rootScope.setLoader(true);
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
                        $rootScope.setLoader(false);
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
                        $rootScope.setLoader(false);
                        console.log(error)
                    })
                }else{
                    $scope.disableSave = false;
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
                            $scope.disableSave = false;
                            $rootScope.setLoader(false);
                            vdm.id = response.data.id;
                            vdm.videoId = response.data.videoId;
                            vdm.classDoc = response.data.classDoc;
                            vdm.writable = false;
                        }, function(error){
                            $scope.disableSave = false;
                            $rootScope.setLoader(false);
                            console.log(error)
                        })
                    }, function(){
                        $scope.disableSave = false;
                        $rootScope.setLoader(false);
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

                if(vdm.status == 'procesado'){
                    if(vdm.classDoc == null || vdm.classDoc.url == null){
                        invalidMsg = "No se puede procesar un video sin primero haber subido el documento de la clase";
                        valid = false;
                    }
                    if(vdm.teacherFiles == null || vdm.teacherFiles.length < 1){
                        invalidMsg = "No se puede procesar un video sin primero haber subido al menos un material de profesor";
                        valid = false;
                    }
                    if(vdm.vdm_type == null || vdm.vdm_type == undefined){
                        invalidMsg = "No se puede procesar un video sin primero indicar su tipo";
                        valid = false;
                    }
                }

                if (!valid) {
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


                if(vdm.prodDept.screen_play == null || vdm.prodDept.screen_play == undefined || vdm.prodDept.screen_play == '' || vdm.prodDept.screen_play.url == null || vdm.prodDept.screen_play.url == undefined || vdm.prodDept.screen_play.url == '') {
                    mesage = "No puede empezar una grabacion sin primero haber guardado un libreto y un guion";
                    valid = false;
                }



                if(vdm.prodDept.script == null || vdm.prodDept.script == undefined || vdm.prodDept.script == '' ||vdm.prodDept.script.url == null || vdm.prodDept.script.url == undefined || vdm.prodDept.script.url == ''){
                    mesage = "No puede empezar una grabacion sin primero haber guardado un libreto y un guion";
                    valid = false;
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
            $rootScope.setLoader(true);
            if (vdm != null){
                var mesage = '';
                var valid = true;
                if(vdm.id != null){
                    if(vdm.prodDept != null && vdm.prodDept.assignment != null){
                        if (vdm.assignmentStatus != null){
                            if(vdm.assignmentStatus == 'editado'){
                                if(vdm.prodDept.assignment.premier_project == null || vdm.prodDept.assignment.premier_project == undefined || vdm.prodDept.assignment.premier_project == '' || vdm.prodDept.assignment.premier_project.url == null ||  vdm.prodDept.assignment.premier_project.url == undefined || vdm.prodDept.assignment.premier_project.url == '' || vdm.prodDept.assignment.video_clip == null || vdm.prodDept.assignment.video_clip == undefined || vdm.prodDept.assignment.video_clip == '' || vdm.prodDept.assignment.video_clip.url == null || vdm.prodDept.assignment.video_clip.url == undefined || vdm.prodDept.assignment.video_clip.url == ''){
                                    mesage = "Debe guardar un video clip y un premier para indicar el estado como editado";
                                    valid = false;
                                }else{
                                    vdm.prodDept.assignment.status = vdm.assignmentStatus;
                                }
                            }
                        }
                    }else{
                        mesage = "No puede guardar una edicion sin que haya una produccion asociada";
                        valid = false;
                    }
                    if(valid){
                        vdm.role = localStorageService.get('currentRole');
                        dawProcessManagerService.updateVdm(vdm, function (response){
                            swal({
                                title: "Exitoso",
                                text: "Se ha actualizado el MDT del video " + response.data.videoId,
                                type: 'success',
                                confirmButtonText: "OK",
                                confirmButtonColor: "lightskyblue"
                            });
                            $rootScope.setLoader(false);
                            $scope.disableSave = false;
                            vdm.writable = false;
                            vdm.prodDept.assignment.status = response.data.prodDept.assignment.status;
                            vdm.prodDept.assignment.comments = response.data.prodDept.assignment.comments;

                        }, function(error){
                            console.log(error);
                            $rootScope.setLoader(false);
                            $scope.disableSave = false;
                        })
                    }else{
                        $rootScope.setLoader(false);
                        $scope.disableSave = false;
                        swal({
                            title: "Aviso",
                            text: mesage,
                            type: 'warning',
                            confirmButtonText: "OK",
                            confirmButtonColor: "lightskyblue"
                        });
                    }

                }
            }
        };

        $scope.saveVdmDesigner = function(vdm){
            $scope.disableSave = true;
            $rootScope.setLoader(true);
            if (vdm != null){
                var mesage = '';
                var valid = true;
                if(vdm.designDept != null && vdm.designDept.assignment != null){
                    if (vdm.assignmentStatus != null){

                        if (vdm.assignmentStatus == 'diseñado'){
                            if(vdm.designDept.assignment.design_ilustrators.length < 1){
                                mesage = "Debe guardar los illustrators para poder cambiar el estado a diseñado";
                                valid = false;
                            }
                            if(vdm.vdm_type == 'wacom' && vdm.designDept.assignment.design_jpgs.length < 1){
                                mesage = "Debe guardar los jpg cuando el video sea de tipo wacom para poder cambiar el estado a diseñado";
                                valid = false;
                            }
                            if(vdm.vdm_type == 'wacom' && vdm.designDept.assignment.designed_presentation.url == null){
                                mesage = "Debe la presentacion diseñada cuando el video sea de tipo wacom para poder cambiar el estado a diseñado";
                                valid = false;
                            }
                        }
                    }
                    if(valid){
                        vdm.designDept.assignment.status = vdm.assignmentStatus;
                        vdm.role = localStorageService.get('currentRole');
                        dawProcessManagerService.updateVdm(vdm, function (response){
                            $rootScope.setLoader(false);
                            swal({
                                title: "Exitoso",
                                text: "Se ha actualizado el MDT del video " + response.data.videoId,
                                type: 'success',
                                confirmButtonText: "OK",
                                confirmButtonColor: "lightskyblue"
                            });
                            $scope.disableSave = false;
                            vdm.writable = false;
                            if(response.data.designDept.assignment != null){
                                vdm.designDept.assignment = response.data.designDept.assignment
                            }

                        }, function(error){
                            console.log(error);
                            $rootScope.setLoader(false);
                            $scope.disableSave = false;
                        })
                    }else{
                        $rootScope.setLoader(false);
                        $scope.disableSave = false;
                        swal({
                            title: "Aviso",
                            text: mesage,
                            type: 'warning',
                            confirmButtonText: "OK",
                            confirmButtonColor: "lightskyblue"
                        });
                    }
                }else{
                    mesage = "No puede guardar un diseño sin que haya un departamento asociado";
                    valid = false;
                }
            }
        };

        $scope.saveVdmPostProducer = function(vdm) {
            $scope.disableSave = true;
            $rootScope.setLoader(true);
            if (vdm != null){
                var mesage = '';
                var valid = true;
                if(vdm.postProdDept != null && vdm.postProdDept.assignment != null){
                    if (vdm.assignmentPostPStatus != null){
                        if (vdm.assignmentPostPStatus == 'terminado'){
                            if(vdm.postProdDept.assignment.video.url == null){
                                mesage = "Debe guardar el video final para cambiar el estado a terminado";
                                valid = false;
                            }
                            if(vdm.postProdDept.assignment.after_project.url == null){
                                mesage = "Debe guardar el proyecto after para cambiar el estado a terminado";
                                valid = false;
                            }
                            if(vdm.postProdDept.assignment.premier_project.url == null){
                                mesage = "Debe guardar el proyecto premier para cambiar el estado a terminado";
                                valid = false;
                            }
                            if(vdm.postProdDept.assignment.illustrators.length < 1){
                                mesage = "Debe guardar al menos un illustrator para cambiar el estado a terminado";
                                valid = false;
                            }
                            if(vdm.postProdDept.assignment.elements.length < 1){
                                mesage = "Debe guardar al menos un elemento para cambiar el estado a terminado";
                                valid = false;
                            }
                        }
                    }

                    if(valid){
                        vdm.postProdDept.assignment.status = vdm.assignmentPostPStatus;
                        vdm.role = localStorageService.get('currentRole');
                        dawProcessManagerService.updateVdm(vdm, function (response){
                            swal({
                                title: "Exitoso",
                                text: "Se ha actualizado el MDT del video " + response.data.videoId,
                                type: 'success',
                                confirmButtonText: "OK",
                                confirmButtonColor: "lightskyblue"
                            });
                            $rootScope.setLoader(false);
                            $scope.disableSave = false;
                            vdm.writable = false;

                        }, function(error){
                            console.log(error);
                            $rootScope.setLoader(false);
                            $scope.disableSave = false;
                        })
                    }else{
                        $rootScope.setLoader(false);
                        $scope.disableSave = false;
                        swal({
                            title: "Aviso",
                            text: mesage,
                            type: 'warning',
                            confirmButtonText: "OK",
                            confirmButtonColor: "lightskyblue"
                        });
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
        
        $scope.approve = function(vdm, department, approval) {
            $scope.disableSave = true;
            $rootScope.setLoader(true);
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
                        if(vdm.qa != null){
                            if (response.data != null){
                                vdm.qa = response.data;
                            }
                        }
                        $rootScope.setLoader(false);
                        $scope.disableSave = false;
                    }, function(error){
                        $rootScope.setLoader(false);
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
                                        $rootScope.setLoader(true);
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
                                                $rootScope.setLoader(false);
                                                $scope.disableSave = false;
                                            }, function(error){
                                                $rootScope.setLoader(false);
                                                $scope.disableSave = false;
                                                console.log(error)
                                            });
                                        }
                                    }, function(){
                                        $rootScope.setLoader(false);
                                        $scope.disableSave = false;
                                    });
                                    break;
                                case 'edition':
                                    swal({
                                        title: 'Justificar rechazo',
                                        input: 'textarea',
                                        type: 'question',
                                        showCancelButton: true
                                    }).then(function(text){
                                        $rootScope.setLoader(true);
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
                                            $rootScope.setLoader(false);
                                            $scope.disableSave = false;
                                        }, function(error){
                                            $rootScope.setLoader(false);
                                            $scope.disableSave = false;
                                            console.log(error)
                                        });
                                    }, function(){
                                        $rootScope.setLoader(false);
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
                                        $rootScope.setLoader(true);
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
                                            $rootScope.setLoader(false);
                                            $scope.disableSave = false;
                                        }, function(error){
                                            $rootScope.setLoader(false);
                                            $scope.disableSave = false;
                                            console.log(error)
                                        });
                                    }, function(){
                                        $rootScope.setLoader(false);
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
                                        $rootScope.setLoader(true);
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
                                            $rootScope.setLoader(false);
                                            $scope.disableSave = false;
                                        }, function(error){
                                            $rootScope.setLoader(false);
                                            $scope.disableSave = false;
                                            console.log(error)
                                        });
                                    }, function(){
                                        $rootScope.setLoader(false);
                                        $scope.disableSave = false;
                                    });
                                    break;
                            }
                        }
                    }, function(){
                        $scope.disableSave = false;
                        $rootScope.setLoader(false);
                    });

                }
            }
        };

        getVdms();

        $scope.uploadPreProductionFiles = function(upload, vdm, doc){
            var valid = true;
            var msg = '';
            $rootScope.setLoader(true);
            var baseUrl = ENV.baseUrl;
            if(vdm.id != null) {
                switch (doc){
                    case 'class_doc':
                        if(upload.type != 'application/vnd.ms-powerpoint' && upload.type != 'application/vnd.openxmlformats-officedocument.presentationml.presentation'){
                            msg = "Los documentos de clase deben ser presentaciones powerpoint para ser guardados";
                            valid = false;
                        }
                        break;
                    case 'teacher_files':
                        angular.forEach(upload, function(file){
                            if(file.type != 'application/pdf' && file.type != 'application/msword' && file.type != 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'){
                                msg = "Los archivos del profesor deben ser pdf o word para ser guardados";
                                valid = false;
                            }
                        });
                        break;
                }
                if(valid){
                    Upload.upload({
                        url: baseUrl+'/api/vdms/upload_pre_production_files?id='+vdm.id+'&doc='+doc,
                        data: {upload: upload}
                    }).then(function (resp) {
                        if(resp.data != null){
                            switch (doc){
                                case 'class_doc':
                                    vdm.classDoc = resp.data.data.class_doc;
                                    vdm.class_doc_name = resp.data.data.class_doc_name;
                                    msg = "Se ha guardado el archivo de forma exitosa";
                                    break;
                                case 'teacher_files':
                                    vdm.teacherFiles = resp.data.data.teacher_files;
                                    msg = "Se han guardado los archivos de forma exitosa";
                                    break;
                            }
                            $rootScope.setLoader(false);
                            swal({
                                title: "Exitoso",
                                text: msg,
                                type: 'success',
                                confirmButtonText: "OK",
                                confirmButtonColor: "lightskyblue"
                            });
                        }else{
                            $rootScope.setLoader(false);
                            swal({
                                title: "ERROR",
                                text: "Ha ocurrido un error al momento de subir los archivos por favor intentelo de nuevo mas tarde",
                                type: 'error',
                                confirmButtonText: "OK",
                                confirmButtonColor: "lightcoral"
                            });
                        }
                        angular.element("input[type='file']").val(null);
                        console.clear();
                    }, function (error) {
                        angular.element("input[type='file']").val(null);
                        $rootScope.setLoader(false);
                        console.log(error);
                    }, function (evt) {
                        var progressPercentage = parseInt(100.0 * evt.loaded / evt.total);
                        console.log('progreso de subida: ' + progressPercentage + '% ');
                    });
                }else{
                    angular.element("input[type='file']").val(null);
                    $rootScope.setLoader(false);
                    swal({
                        title: "Aviso",
                        text: msg,
                        type: 'warning',
                        confirmButtonText: "OK",
                        confirmButtonColor: "lightcoral"
                    });
                }
            }
        };
        $scope.uploadEditionFiles = function(file, vdm, file_type){
            var valid = true;
            var msg = '';
            $rootScope.setLoader(true);
            var baseUrl = ENV.baseUrl;
            if(vdm.prodDept != null && vdm.prodDept.assignment != null) {
                var regex;
                switch (file_type){
                    case 'video_clip':
                        regex = new RegExp("(.*?)\.(mp4)$");
                        if(!(regex.test(file.name.toLowerCase()))){
                            msg = "Los videos deben ser mp4 para poder ser guardados";
                            valid = false;
                        }
                        break;
                    case 'premier':
                        regex = new RegExp("(.*?)\.(prproj)$");
                        if(!(regex.test(file.name.toLowerCase()))){
                            msg = "Los proyectos premier deben ser .prproj para poder ser guardados";
                            valid = false;
                        }
                        break;
                }

                if(valid){
                    Upload.upload({
                        url: baseUrl+'/api/vdms/upload_edition_files?id='+vdm.id+'&file_type='+file_type,
                        data: {file: file}
                    }).then(function (resp) {
                        if(resp.data != null){
                            switch(file_type){
                                case 'video_clip':
                                    vdm.prodDept.assignment.video_clip = resp.data.data.video_clip;
                                    vdm.prodDept.assignment.video_clip_name = resp.data.data.video_clip_name;
                                    break;

                                case 'premier':
                                    vdm.prodDept.assignment.premier_project = resp.data.data.premier_project;
                                    vdm.prodDept.assignment.premier_project_name = resp.data.data.premier_project_name;
                                    break;
                                default:
                                    angular.element("input[type='file']").val(null);
                                    console.log('Archivo no permitido')
                            }

                        }
                        $rootScope.setLoader(false);
                        swal({
                            title: "Exitoso",
                            text: 'Se ha guardado el archivo de forma exitosa',
                            type: 'success',
                            confirmButtonText: "OK",
                            confirmButtonColor: "lightskyblue"
                        });
                        angular.element("input[type='file']").val(null);
                        console.clear();
                    }, function (error) {
                        angular.element("input[type='file']").val(null);
                        $rootScope.setLoader(false);
                        console.log(error);
                    }, function (evt) {
                        var progressPercentage = parseInt(100.0 * evt.loaded / evt.total);
                        console.log('progreso de subida: ' + progressPercentage + '% ');
                    });
                }else{
                    angular.element("input[type='file']").val(null);
                    $rootScope.setLoader(false);
                    swal({
                        title: "Aviso",
                        text: msg,
                        type: 'error',
                        confirmButtonText: "OK",
                        confirmButtonColor: "lightcoral"
                    });
                }
            }else {
                angular.element("input[type='file']").val(null);
                $rootScope.setLoader(false);
                swal({
                    title: "Fallido",
                    text: 'No puede guardar una edicion sin que haya una produccion asociada',
                    type: 'error',
                    confirmButtonText: "OK",
                    confirmButtonColor: "lightcoral"
                });

            }
        };
        $scope.uploadDesignFiles = function(upload, vdm, type){
            var valid = true;
            var msg = '';
            $rootScope.setLoader(true);
            var baseUrl = ENV.baseUrl;
            if(vdm.designDept != null && vdm.designDept.assignment != null) {
                switch (type){
                    case 'ilustrators':
                        angular.forEach(upload, function(file){
                            if(file.type != 'application/postscript' && file.type != 'application/illustrator'){
                                msg = "Los archivos deben ser .ai guardados";
                                valid = false;
                            }
                        });
                        break;
                    case 'jpgs':
                        angular.forEach(upload, function(file){
                            if(file.type != 'image/jpeg' && file.type != 'image/png'){
                                msg = "Los archivos deben ser imagenes para ser guardados";
                                valid = false;
                            }
                        });
                        break;
                    case 'designed_presentation':
                        if(upload.type != 'application/pdf'){
                            msg = "Las presentaciones diseñadas deben ser pdf";
                            valid = false;
                        }
                        break;
                }
                if(valid){
                    Upload.upload({
                        url: baseUrl+'/api/vdms/upload_design_files?id='+vdm.id+'&type='+type,
                        data: {upload: upload}
                    }).then(function (resp) {
                        if(resp.data != null){
                            switch (type){
                                case 'ilustrators':
                                    vdm.designDept.assignment.design_ilustrators = resp.data.data.design_ilustrators;
                                    msg = "Se han guardado los archivos de forma exitosa";
                                    break;
                                case 'jpgs':
                                    vdm.designDept.assignment.design_jpgs = resp.data.data.design_jpgs;
                                    msg = "Se han guardado los archivos de forma exitosa";
                                    break;
                            }
                            $rootScope.setLoader(false);
                            swal({
                                title: "Exitoso",
                                text: msg,
                                type: 'success',
                                confirmButtonText: "OK",
                                confirmButtonColor: "lightskyblue"
                            });
                        }else{
                            $rootScope.setLoader(false);
                            swal({
                                title: "ERROR",
                                text: "Ha ocurrido un error al momento de subir los archivos por favor intentelo de nuevo mas tarde",
                                type: 'error',
                                confirmButtonText: "OK",
                                confirmButtonColor: "lightcoral"
                            });
                        }
                        angular.element("input[type='file']").val(null);
                        console.clear();
                    }, function (error) {
                        angular.element("input[type='file']").val(null);
                        $rootScope.setLoader(false);
                        console.log(error);
                    }, function (evt) {
                        var progressPercentage = parseInt(100.0 * evt.loaded / evt.total);
                        console.log('progreso de subida: ' + progressPercentage + '% ');
                    });
                }else{
                    angular.element("input[type='file']").val(null);
                    $rootScope.setLoader(false);
                    swal({
                        title: "Aviso",
                        text: msg,
                        type: 'warning',
                        confirmButtonText: "OK",
                        confirmButtonColor: "lightcoral"
                    });
                }
            }else{
                angular.element("input[type='file']").val(null);
                $rootScope.setLoader(false);
                swal({
                    title: "ERROR",
                    text: 'Ha ocurrido un error inesperado por favor intentelo de nuevo mas tarde',
                    type: 'error',
                    confirmButtonText: "OK",
                    confirmButtonColor: "lightcoral"
                });
            }
        };
        $scope.uploadProductionFiles = function(upload, vdm, doc){
            var valid = true;
            var msg = '';
            $rootScope.setLoader(true);
            var baseUrl = ENV.baseUrl;
            if(vdm.id != null) {
                switch (doc){
                    case 'screen_play':
                        if(upload.type != 'application/vnd.ms-powerpoint' && upload.type != 'application/vnd.openxmlformats-officedocument.presentationml.presentation' && upload.type != 'application/pdf'){
                            msg = "Los guiones deben ser presentaciones powerpoint o archivos pdf para ser guardados";
                            valid = false;
                        }
                        break;
                    case 'script':

                        if(upload.type != 'application/pdf' && upload.type != 'application/vnd.ms-excel' && upload.type != 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'){
                            msg = "Los libretos deben ser archivos excel o archivos pdf para ser guardados";
                            valid = false;
                        }

                        break;
                }
                if(valid){
                    Upload.upload({
                        url: baseUrl+'/api/vdms/upload_production_files?id='+vdm.id+'&doc='+doc,
                        data: {upload: upload}
                    }).then(function (resp) {
                        if(resp.data != null){
                            switch (doc){
                                case 'screen_play':
                                    vdm.prodDept.screen_play = resp.data.data.screen_play;
                                    vdm.prodDept.screen_play_name = resp.data.data.screen_play_name;
                                    break;
                                case 'script':
                                    vdm.prodDept.script = resp.data.data.script;
                                    vdm.prodDept.script_name = resp.data.data.script_name;
                                    break;
                            }
                            $rootScope.setLoader(false);
                            swal({
                                title: "Exitoso",
                                text: "Se ha guardado el archivo de forma exitosa",
                                type: 'success',
                                confirmButtonText: "OK",
                                confirmButtonColor: "lightskyblue"
                            });
                        }else{
                            $rootScope.setLoader(false);
                            swal({
                                title: "ERROR",
                                text: "Ha ocurrido un error al momento de subir los archivos por favor intentelo de nuevo mas tarde",
                                type: 'error',
                                confirmButtonText: "OK",
                                confirmButtonColor: "lightcoral"
                            });
                        }
                        angular.element("input[type='file']").val(null);
                        console.clear();
                    }, function (error) {
                        angular.element("input[type='file']").val(null);
                        $rootScope.setLoader(false);
                        console.log(error);
                    }, function (evt) {
                        var progressPercentage = parseInt(100.0 * evt.loaded / evt.total);
                        console.log('progreso de subida: ' + progressPercentage + '% ');
                    });
                }else{
                    angular.element("input[type='file']").val(null);
                    $rootScope.setLoader(false);
                    swal({
                        title: "Aviso",
                        text: msg,
                        type: 'warning',
                        confirmButtonText: "OK",
                        confirmButtonColor: "lightcoral"
                    });
                }
            }
        };
        $scope.uploadPostProductionFiles = function(upload, vdm, file_type){
            var valid = true;
            var msg = '';
            var regex;
            $rootScope.setLoader(true);
            var baseUrl = ENV.baseUrl;
            if(vdm.id != null) {
                switch (file_type){
                    case 'final_vid':
                        regex = new RegExp("(.*?)\.(mp4)$");
                        if(!(regex.test(upload.name.toLowerCase()))){
                            msg = "Los videos deben ser mp4 para poder ser guardados";
                            valid = false;
                        }
                        break;
                    case 'premier_project':
                        regex = new RegExp("(.*?)\.(prproj)$");
                        if(!(regex.test(upload.name.toLowerCase()))){
                            msg = "Los proyectos premier deben ser .prproj para poder ser guardados";
                            valid = false;
                        }
                        break;
                    case 'after_project':
                        regex = new RegExp("(.*?)\.(aep)$");
                        if(!(regex.test(upload.name.toLowerCase()))){
                            msg = "Los proyectos after deben ser .aep para poder ser guardados";
                            valid = false;
                        }
                        break;
                    case 'illustrators':
                        regex = new RegExp("(.*?)\.(ai)$");
                        angular.forEach(upload, function(file){
                            if(!(regex.test(file.name.toLowerCase()))){
                                msg = "Los illustrator deben ser .ai para ser guardados";
                                valid = false;
                            }
                        });
                        break;
                }
                if(valid){
                    Upload.upload({
                        url: baseUrl+'/api/vdms/upload_post_production_files?id='+vdm.id+'&file_type='+file_type,
                        data: {upload: upload}
                    }).then(function (resp) {
                        if(resp.data != null){
                            switch (file_type){
                                case 'final_vid':
                                    vdm.postProdDept.assignment.video = resp.data.data.video;
                                    vdm.postProdDept.assignment.video_name = resp.data.data.video_name;
                                    msg = "Se ha guardado el archivo de forma exitosa";
                                    break;
                                case 'premier_project':
                                    vdm.postProdDept.assignment.premier_project = resp.data.data.premier_project;
                                    vdm.postProdDept.assignment.premier_project_name = resp.data.data.premier_project_name;
                                    msg = "Se ha guardado el archivo de forma exitosa";
                                    break;
                                case 'after_project':
                                    vdm.postProdDept.assignment.after_project = resp.data.data.after_project;
                                    vdm.postProdDept.assignment.after_project_name = resp.data.data.after_project_name;
                                    msg = "Se ha guardado el archivo de forma exitosa";
                                    break;
                                case 'illustrators':
                                    vdm.postProdDept.assignment.illustrators = resp.data.data.illustrators;
                                    msg = "Se han guardado los archivos de forma exitosa";
                                    break;
                                case 'elements':
                                    vdm.postProdDept.assignment.elements = resp.data.data.elements;
                                    msg = "Se han guardado los archivos de forma exitosa";
                                    break;
                            }
                            $rootScope.setLoader(false);
                            swal({
                                title: "Exitoso",
                                text: msg,
                                type: 'success',
                                confirmButtonText: "OK",
                                confirmButtonColor: "lightskyblue"
                            });
                        }else{
                            $rootScope.setLoader(false);
                            swal({
                                title: "ERROR",
                                text: "Ha ocurrido un error al momento de subir los archivos por favor intentelo de nuevo mas tarde",
                                type: 'error',
                                confirmButtonText: "OK",
                                confirmButtonColor: "lightcoral"
                            });
                        }
                        angular.element("input[type='file']").val(null);
                        console.clear();
                    }, function (error) {
                        angular.element("input[type='file']").val(null);
                        $rootScope.setLoader(false);
                        console.log(error);
                    }, function (evt) {
                        var progressPercentage = parseInt(100.0 * evt.loaded / evt.total);
                        console.log('progreso de subida: ' + progressPercentage + '% ');
                    });
                }else{
                    angular.element("input[type='file']").val(null);
                    $rootScope.setLoader(false);
                    swal({
                        title: "Aviso",
                        text: msg,
                        type: 'warning',
                        confirmButtonText: "OK",
                        confirmButtonColor: "lightcoral"
                    });
                }
            }
        };
        $scope.$watch('localStorageService.get("currentRole")', function (newVal, oldVal) {
            if(newVal !== oldVal){
                getVdms();
            }

        })
    }]);
