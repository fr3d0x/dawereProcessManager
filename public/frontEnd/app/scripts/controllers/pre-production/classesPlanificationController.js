/**
 * Created by fr3d0 on 7/25/16.
 */
'use strict';
app.controller("classesPlanificationController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', 'NgTableParams', '$filter',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, NgTableParams, $filter){
        var getClassesPlan = function(){
            dawProcessManagerService.getClassesPlaning($stateParams.id, function (response)  {
                $scope.subject = response.subject;
                $scope.emptyResponse = false;
                if (response.data != null){
                    var data = response.data;
                    $scope.subjectPlaning = response.data;
                    $scope.tableParams = new NgTableParams({},{
                        filterOptions: { filterLayout: "horizontal" },
                        dataset: data.classesPlaning
                    });
                }else{
                    $scope.emptyResponse = true;
                }
            }, function(error) {
                alert(error);
            })
        };

        var getCpsToFuse = function(cps, cp){
            var cpsToFuse = {};

            for (var i = 0; i<cps.length; i++){
                if(cps[i].id != null && cps[i].topicName != '' && cps[i].topicName != null && cps[i].topicName != cp.topicName ){
                    cpsToFuse[cps[i].id] = cps[i].topicName
                }
            }
            return cpsToFuse;

        };
        $scope.remove = function(element, array){
            if (element != null){
                if(element.id != null){
                    swal({
                        title: "Justifique",
                        text: "Por que desea eliminar este elemento",
                        type: "question",
                        showCancelButton: true,
                        confirmButtonText: "OK",
                        input: 'textarea'

                    }).then(function(text) {
                        element.justification = text;
                        dawProcessManagerService.deleteCp(element, function(response){
                            swal({
                                title: "Exitoso",
                                text: "Se ha eliminado el elemento",
                                type: 'success',
                                confirmButtonText: "OK"
                            });
                            element.id = response.data.id;
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

        $scope.save = function(cp, sp){
            if (cp != null && sp != null){
                cp.subjectId = sp.subject.id;
                cp.subjectPlanId = sp.id;
                if(cp.id != null){
                    dawProcessManagerService.editCP(cp, function (response){
                        swal({
                            title: "Exitoso",
                            text: "Se ha Actualizado el el plan de clases del tema " + cp.topicName,
                            type: 'success',
                            confirmButtonText: "OK",
                            confirmButtonColor: "lightskyblue"
                        });
                        cp.writable = false;
                        cp.topicNumber = response.data.topicNumber
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
                        cp.justification = text;
                        dawProcessManagerService.saveCp(cp, function(response){
                            swal({
                                title: "Exitoso",
                                text: "Se ha Guardado el el plan de clases del tema " + response.data.topicName,
                                type: 'success',
                                confirmButtonText: "OK"
                            });
                            cp.id = response.data.id;
                            cp.vdms = response.data.videos;
                            cp.writable = false;
                            cp.topicNumber = response.data.topicNumber
                            cp.newRow = false;
                        }, function(error){
                            console.log(error)
                        })
                    }, function(){});

                }

            }
        };

        $scope.close = function(cp, arr){
            if(cp.id != null){
                cp.writable = false;
            }else{
                arr.splice(arr.indexOf(cp), 1)
            }

        };
        $scope.editRow = function(row){
            row.writable = true;
        };
        $scope.add = function(cp, data){
            data.splice(data.indexOf(cp)+1, 0, {
                meGeneralObjective: null,
                meSpecificObjective: null,
                meSpecificObjDesc: null,
                topicName: null,
                writable: true,
                newRow: true
            });
        };

        $scope.merge = function(cp, data){
          if(cp != null){
              if (cp.id != null){
                  swal({
                      title: 'Seleccione el plan de clases que quiere fusionar con este',
                      input: 'select',
                      inputOptions: getCpsToFuse(data, cp),
                      inputPlaceholder: 'Seleccione',
                      showCancelButton: true,
                      inputValidator: function(value) {
                          return new Promise(function(resolve, reject) {
                              if (value != '') {
                                  resolve();
                              } else {
                                  reject('Seleccione un plan de clases o presione cancelar)');
                              }
                          });
                      }
                  }).then(function(result){
                      if(result != null){
                          var request = {};
                          var cp2 = {};
                          for (var i = 0; i < data.length; i++){
                              if(data[i].id == result){
                                  cp2 = data[i];
                              }
                          }
                          request.merge = cp.id;
                          request.mergeWith = parseInt(result);
                          $("body").css("cursor", "progress");
                          $scope.disableSave = true;
                          dawProcessManagerService.mergeClassPlans(request, function (response){
                              $("body").css("cursor", "default");
                              $scope.disableSave = false;
                              swal({
                                  title: "Exitoso",
                                  text: "Se ha fusionado el plan de clases del tema " + cp.topicName + " con el plan de clases del tema " + cp2.topicname ,
                                  type: 'success',
                                  confirmButtonText: "OK",
                                  confirmButtonColor: "lightskyblue"
                              }).then(function(){
                                  location.reload();
                              }, function(){});
                              if(response.data != null){
                                  cp2.vdms = cp2.vdms.concat(response.data);
                              }
                              data.splice(data.indexOf(cp), 1)
                          }, function(error){
                              console.log(error);
                          });
                      }
                  }, function(){
                      $("body").css("cursor", "default");
                      $scope.disableSave = false;
                  })
              }
          }
        };
        getClassesPlan();
    }]);
