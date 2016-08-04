/**
 * Created by fr3d0 on 7/29/16.
 */
app.controller("showVdmController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', 'NgTableParams', '$filter',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, NgTableParams, $filter){
        var getVdm = function(){
            dawProcessManagerService.getVdm($stateParams.id, function (response)  {
                
                $scope.vdm = response.data;
                $scope.tableParams = new NgTableParams({},{
                    filterOptions: { filterLayout: "horizontal" },
                    dataset: response.data.changes
                });
            }, function(error) {
                alert(error);
            })
        };

        $scope.showScript = function(data){
            window.open("data:application/pdf;base64, " + data);
        };
        
        getVdm()
    }]);