/**
 * Created by fr3d0 on 7/25/16.
 */

app.controller("classesPlanificationController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', 'NgTableParams', '$filter',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, NgTableParams, $filter){
        var getClassesPlan = function(){
            dawProcessManagerService.getClassesPlaning($stateParams.id, function (response)  {
                var data = response.data;
                $scope.subject = data.subject;
                $scope.tableParams = new NgTableParams({},{
                    filterOptions: { filterLayout: "horizontal" },
                    dataset: data.classesPlaning
                });
            }, function(error) {
                alert(error);
            })
        };


        getClassesPlan();
    }]);
