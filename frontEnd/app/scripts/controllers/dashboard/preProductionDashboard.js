/**
 * Created by fr3d0 on 25/07/16.
 */

'use strict';
app.controller("preProductionDashboardController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService){

        var getGlobalProgress = function(){
            dawProcessManagerService.getGlobalProgress(function (response)  {
                var data = response.data;
                $scope.tableParams = new NgTableParams({},{
                    filterOptions: { filterLayout: "horizontal" },
                    dataset: data
                });
            }, function(error) {
                alert(error);
            })
        };


        getGlobalProgress();
        
    }]);