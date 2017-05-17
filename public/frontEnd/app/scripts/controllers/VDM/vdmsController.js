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
            if (vdm.productionStatus != null){
                if (vdm.productionStatus == 'grabado' || vdm.productionStatus == 'aprobado' || vdm.productionStatus == 'por aprobar'){
                    departments['production'] = 'Produccion';
                }
            }
            if (vdm.editionStatus != null){
                if (vdm.editionStatus == 'editado' || vdm.editionStatus == 'aprobado' || vdm.editionStatus == 'por aprobar'){
                    departments['edition'] = 'Edicion'
                }
            }
            if (vdm.designStatus != null){
                if (vdm.designStatus == 'diseñado' || vdm.designStatus == 'por aprobar'|| vdm.designStatus == 'aprobado'){
                    departments['design'] = 'Diseño'
                }
            }
            if (vdm.postProdStatus != null){
                if (vdm.postProdStatus == 'terminado' || vdm.postProdStatus == 'por aprobar' || 'por aprobar qa'){
                    departments['postProduction'] = 'Post-Produccion'
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
                                                if (vdm.prodDept != null){
                                                    if (response.data.prodDept){
                                                        vdm.prodDept.intro = response.data.prodDept.intro;
                                                        vdm.intro = vdm.prodDept.intro;
                                                        vdm.prodDept.conclu = response.data.prodDept.conclu;
                                                        vdm.conclu = vdm.prodDept.conclu;
                                                        vdm.prodDept.vidDev = response.data.prodDept.vidDev;
                                                        vdm.vidDev = vdm.prodDept.vidDev;
                                                        vdm.prodDept.status = response.data.prodDept.status;
                                                        if(response.data.prodDept.assignment != null){
                                                            if (vdm.prodDept.assignment){
                                                                vdm.prodDept.assignment.assignedName = response.data.prodDept.assignment.assignedName;
                                                                vdm.prodDept.assignment.id = response.data.prodDept.assignment.id;
                                                                vdm.prodDept.assignment.status = response.data.prodDept.assignment.status;
                                                            }
                                                        }
                                                    }
                                                }
                                                if(vdm.productManagement != null){
                                                    if (response.data.productManagement != null){
                                                        vdm.productManagement = response.data.productManagement;
                                                    }
                                                }
                                                if (vdm.designDept != null){
                                                    if(response.data.designDept != null){
                                                        vdm.designDept = response.data.designDept;
                                                    }
                                                }
                                                if(vdm.postProdDept != null){
                                                    if(response.data.postProdDept != null){
                                                        vdm.postProdDept = response.data.postProdDept;
                                                    }
                                                }
                                                if (vdm.qa != null){
                                                    if(response.data.qa != null){
                                                        vdm.qa = response.data.qa
                                                    }
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
                                            if (vdm.prodDept != null){
                                                if (response.data.prodDept){
                                                    vdm.prodDept.intro = response.data.prodDept.intro;
                                                    vdm.intro = vdm.prodDept.intro;
                                                    vdm.prodDept.conclu = response.data.prodDept.conclu;
                                                    vdm.conclu = vdm.prodDept.conclu;
                                                    vdm.prodDept.vidDev = response.data.prodDept.vidDev;
                                                    vdm.vidDev = vdm.prodDept.vidDev;
                                                    vdm.prodDept.status = response.data.prodDept.status;
                                                    if(response.data.prodDept.assignment != null){
                                                        if (vdm.prodDept.assignment){
                                                            vdm.prodDept.assignment.assignedName = response.data.prodDept.assignment.assignedName;
                                                            vdm.prodDept.assignment.id = response.data.prodDept.assignment.id;
                                                            vdm.prodDept.assignment.status = response.data.prodDept.assignment.status;
                                                        }
                                                    }
                                                }
                                            }
                                            if(vdm.productManagement != null){
                                                if (response.data.productManagement != null){
                                                    vdm.productManagement = response.data.productManagement;
                                                }
                                            }
                                            if (vdm.designDept != null){
                                                if(response.data.designDept != null){
                                                    vdm.designDept = response.data.designDept;
                                                }
                                            }
                                            if(vdm.postProdDept != null){
                                                if(response.data.postProdDept != null){
                                                    vdm.postProdDept = response.data.postProdDept;
                                                }
                                            }
                                            if (vdm.qa != null){
                                                if(response.data.qa != null){
                                                    vdm.qa = response.data.qa
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

                                            if (vdm.prodDept != null){
                                                if (response.data.prodDept){
                                                    vdm.prodDept.intro = response.data.prodDept.intro;
                                                    vdm.intro = vdm.prodDept.intro;
                                                    vdm.prodDept.conclu = response.data.prodDept.conclu;
                                                    vdm.conclu = vdm.prodDept.conclu;
                                                    vdm.prodDept.vidDev = response.data.prodDept.vidDev;
                                                    vdm.vidDev = vdm.prodDept.vidDev;
                                                    vdm.prodDept.status = response.data.prodDept.status;
                                                    if(response.data.prodDept.assignment != null){
                                                        if (vdm.prodDept.assignment){
                                                            vdm.prodDept.assignment.assignedName = response.data.prodDept.assignment.assignedName;
                                                            vdm.prodDept.assignment.id = response.data.prodDept.assignment.id;
                                                            vdm.prodDept.assignment.status = response.data.prodDept.assignment.status;
                                                        }
                                                    }
                                                }
                                            }
                                            if(vdm.productManagement != null){
                                                if (response.data.productManagement != null){
                                                    vdm.productManagement = response.data.productManagement;
                                                }
                                            }
                                            if (vdm.designDept != null){
                                                if(response.data.designDept != null){
                                                    vdm.designDept = response.data.designDept;
                                                }
                                            }
                                            if(vdm.postProdDept != null){
                                                if(response.data.postProdDept != null){
                                                    vdm.postProdDept = response.data.postProdDept;
                                                }
                                            }
                                            if (vdm.qa != null){
                                                if(response.data.qa != null){
                                                    vdm.qa = response.data.qa
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

                                            if (vdm.prodDept != null){
                                                if (response.data.prodDept){
                                                    vdm.prodDept.intro = response.data.prodDept.intro;
                                                    vdm.intro = vdm.prodDept.intro;
                                                    vdm.prodDept.conclu = response.data.prodDept.conclu;
                                                    vdm.conclu = vdm.prodDept.conclu;
                                                    vdm.prodDept.vidDev = response.data.prodDept.vidDev;
                                                    vdm.vidDev = vdm.prodDept.vidDev;
                                                    vdm.prodDept.status = response.data.prodDept.status;
                                                    if(response.data.prodDept.assignment != null){
                                                        if (vdm.prodDept.assignment){
                                                            vdm.prodDept.assignment.assignedName = response.data.prodDept.assignment.assignedName;
                                                            vdm.prodDept.assignment.id = response.data.prodDept.assignment.id;
                                                            vdm.prodDept.assignment.status = response.data.prodDept.assignment.status;
                                                        }
                                                    }
                                                }
                                            }
                                            if(vdm.productManagement != null){
                                                if (response.data.productManagement != null){
                                                    vdm.productManagement = response.data.productManagement;
                                                }
                                            }
                                            if (vdm.designDept != null){
                                                if(response.data.designDept != null){
                                                    vdm.designDept = response.data.designDept;
                                                }
                                            }
                                            if(vdm.postProdDept != null){
                                                if(response.data.postProdDept != null){
                                                    vdm.postProdDept = response.data.postProdDept;
                                                }
                                            }
                                            if (vdm.qa != null){
                                                if(response.data.qa != null){
                                                    vdm.qa = response.data.qa
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
            var selected_files = '';
            var baseUrl = ENV.baseUrl;
            if(vdm.id != null) {
                switch (doc){
                    case 'class_doc':
                        if(upload.type != 'application/vnd.ms-powerpoint' && upload.type != 'application/vnd.openxmlformats-officedocument.presentationml.presentation'){
                            msg = "Los documentos de clase deben ser presentaciones powerpoint para ser guardados";
                            valid = false;
                        }
                        selected_files = upload.name;
                        break;
                    case 'teacher_files':
                        angular.forEach(upload, function(file){
                            if(file.type != 'application/pdf' && file.type != 'application/msword' && file.type != 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'){
                                msg = "Los archivos del profesor deben ser pdf o word para ser guardados";
                                valid = false;
                            }
                            selected_files = "los archivos "+ selected_files + file.name;
                            if(upload.indexOf(file) != upload.length - 1 ){
                                selected_files = selected_files + ', '
                            }
                        });
                        break;
                }
                if(valid){
                    swal({
                        title: 'Esta seguro',
                        text: "Esta seguro que desea subir " + selected_files + ".Para " + vdm.videoId + "?",
                        type: 'warning',
                        showCancelButton: true,
                        confirmButtonColor: 'lightskyblue',
                        cancelButtonColor: 'lightcoral',
                        confirmButtonText: 'OK',
                        cancelButtonText: 'Cancel'
                    }).then(function () {
                        $rootScope.setLoader(true);
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
                       
                    }, function (dismiss) {
                        angular.element("input[type='file']").val(null);
                        console.clear();
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
                        Upload.mediaDuration(file).then(function(duration){
                            var validDuration = 720;
                            if(duration > validDuration){
                                msg = "Los videos deben durar menos de 12 minutos para poder ser guardados";
                                valid = false;
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
                        });
                        break;
                    case 'premier':
                        regex = new RegExp("(.*?)\.(prproj)$");
                        if(!(regex.test(file.name.toLowerCase()))){
                            msg = "Los proyectos premier deben ser .prproj para poder ser guardados";
                            valid = false;
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
                        break;
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
            var regex;
            $rootScope.setLoader(true);
            var baseUrl = ENV.baseUrl;
            if(vdm.designDept != null && vdm.designDept.assignment != null) {
                switch (type){
                    case 'ilustrators':
                        angular.forEach(upload, function(file){
                            regex = new RegExp("(.*?)\.(ai)$");
                            if(!(regex.test(file.name.toLowerCase()))){
                                msg = "Estos archivos deben ser illustrators para ser guardados";
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
                                case 'designed_presentation':
                                    vdm.designDept.assignment.designed_presentation = resp.data.data.designed_presentation;
                                    vdm.designDept.assignment.designed_presentation_name = resp.data.data.designed_presentation_name;

                                    msg = "Se han guardado los archivos de forma exitosa";
                                case 'elements':
                                    vdm.designDept.assignment.design_elements = resp.data.data.elements;
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
        $scope.printVdmInfo = function(vdms, department, employee, status, total, subject){
            var report_title = '';
            var validDoc = false;
            var arr = [];
            if (department != null && employee){
                validDoc = true;
                if (total){
                    report_title = 'Estado del total de videos de ' + subject + 'asignados a' + department;
                }else{
                    report_title = 'Videos ' + status + ' de ' + subject + 'asignados a' + department;
                }
            }
            angular.forEach(vdms, function(vdm){
                arr.push(

                )
            });
            var docDefinition = {
                background: {
                    image: logo,
                    fit: [500, 300],
                    margin: [ 50, 350, 5, 20 ]
                },
                content: [
                    { text: 'Informacion de MDT', margin: [ 135, 2, 5, 25 ], fontSize: 24, bold: true },

                    { text: [{text: 'Id del video: ', fontSize: 12, bold: true},
                        {text: videoId, fontSize: 11}
                    ], margin: [ 15, 2, 5, 20 ]},
                    { text: [{text: 'Nombre del tema: ', fontSize: 12, bold: true},
                        {text: topicName, margin: [ 15, 2, 5, 20 ], fontSize: 11}
                    ], margin: [ 15, 2, 5, 20 ]},
                    { text: [{text: 'Descripcion de objetivo especifico del tema: ', fontSize: 12, bold: true},
                        {text: soDesc, fontSize: 11}
                    ], margin: [ 15, 2, 5, 20 ]},
                    { text: [{text: 'Título del video: ', fontSize: 12, bold: true},
                        {text: videoTittle, fontSize: 11}
                    ], margin: [ 15, 2, 5, 20 ]},
                    { text: [{text: 'Contenido del video: ', fontSize: 12, bold: true},
                        {text: videoContent, fontSize: 11}
                    ], margin: [ 15, 2, 5, 20 ]},
                    { text: [{text: 'Comentarios pre-produccion: ', fontSize: 12, bold: true},
                        {text: comments, fontSize: 11}
                    ], margin: [ 15, 2, 5, 20 ]},
                    { text: [{text: 'Descripcion pre-produccion: ', fontSize: 12, bold: true},
                        {text: description, fontSize: 11}
                    ], margin: [ 15, 2, 5, 20 ]}
                ]
            };
            pdfMake.createPdf(docDefinition).open();
        };
        $scope.$watch('localStorageService.get("currentRole")', function (newVal, oldVal) {
            if(newVal !== oldVal){
                getVdms();
            }

        });

        var logo = 'data:image/png;base64,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';
    }]);
