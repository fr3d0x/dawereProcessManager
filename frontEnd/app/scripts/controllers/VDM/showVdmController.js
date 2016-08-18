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
                    dataset: response.data.changes
                });
            }, function(error) {
                alert(error);
            })
        };
        
        getVdm()
    }]);