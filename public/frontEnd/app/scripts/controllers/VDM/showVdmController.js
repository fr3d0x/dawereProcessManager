/**
 * Created by fr3d0 on 7/29/16.
 */
app.controller("showVdmController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', 'NgTableParams', '$filter',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, NgTableParams, $filter){
        var getVdm = function(){
            dawProcessManagerService.getVdm($stateParams.id, function (response)  {
                
                $scope.vdm = response.data;
                $scope.tableParams = new NgTableParams({
                    sorting: {
                        created_at: 'desc'
                    }
                },{
                    filterOptions: { filterLayout: "horizontal" },
                    dataset: response.data.changes,
                    groupBy: 'department'

                });
            }, function(error) {
                alert(error);
            })
        };

        $scope.printVdmInfo = function(vdm){
            var videoId = '';
            var topicName = '';
            var soDesc = '';
            var videoTittle = '';
            var videoContent = '';
            var comments = '';
            var description = '';

            if (vdm.videoId != null){
                videoId = vdm.videoId
            }
            if (vdm.cp.topicName != null){
                topicName = vdm.cp.topicName
            }
            if (vdm.cp.meSpecificObjDesc != null){
                soDesc = vdm.cp.meSpecificObjDesc
            }
            if (vdm.videoTittle != null){
                videoTittle = vdm.videoTittle
            }
            if (vdm.videoContent != null){
                videoContent = vdm.videoContent
            }
            if (vdm.comments != null){
                comments = vdm.comments
            }
            if (vdm.description != null){
                description = vdm.description
            }
            var docDefinition = {
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
        
        getVdm()
    }]);