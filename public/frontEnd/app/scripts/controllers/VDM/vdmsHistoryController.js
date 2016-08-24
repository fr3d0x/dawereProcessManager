/**
 * Created by fr3d0 on 7/30/16.
 */
'use strict';

app.controller("vdmsHistoryController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', 'NgTableParams', '$filter',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, NgTableParams, $filter) {
        var getVdmsHixtory = function () {
            dawProcessManagerService.getVdmsHistoryBySubject($stateParams.id, function (response) {
                $scope.subject = response.data.subject;
                $scope.tableParams = new NgTableParams({
                    sorting: {
                        created_at: 'desc'
                    }
                }, {
                    filterOptions: {filterLayout: "horizontal"},
                    dataset: response.data.history,
                    groupBy: 'department'
                });
            }, function (error) {
                alert(error);
            })
        };
        
        getVdmsHixtory();
    }]);